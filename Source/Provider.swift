//
// Provider.swift
//
// Copyright (c) 2016 Damien (http://delba.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

public class Provider: NSObject {
    public let clientID: String
    public let clientSecret: String
    
    public let authorizeURL: NSURL
    public let tokenURL: NSURL
    public let redirectURL: NSURL
    
    public var scope: String?
    public var state: String?
    
    public var additionalParamsForAuthorization:  [String: AnyObject] = [:]
    public var additionalParamsForTokenRequest: [String: AnyObject] = [:]
    
    public var completion: (Result<Token, Error> -> Void)?
    
    private var safariVC: UIViewController?
    
    public init(clientID: String, clientSecret: String, authorizeURL: String, tokenURL: String, redirectURL: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.authorizeURL = NSURL(string: authorizeURL)!
        self.tokenURL = NSURL(string: tokenURL)!
        self.redirectURL = NSURL(string: redirectURL)!
    }
    
    public func authorize(completion: Result<Token, Error> -> Void) {
        self.completion = completion
        
        var params = [
            "client_id": clientID,
            "redirect_uri": redirectURL.absoluteString,
            "scope": scope,
            "state": state
        ]
        
        additionalParamsForAuthorization.forEach { params[$0] = String($1) }
        
        visit(URL: authorizeURL.query(params))
    }
    
    public func handleURL(URL: NSURL, options: [String: AnyObject]) {
        guard shouldHandleURL(URL, options: options) else { return }
        
        NotificationCenter.removeObserver(self, name: UIApplicationDidBecomeActiveNotification)
        
        guard let code = URL.query("code") else {
            failure(Error(URL.query))
            return
        }
        
        requestToken(code: code) { [weak self] result in
            guard let this = self else { return }
            
            switch result {
            case .Success(let token):
                this.success(token)
            case .Failure(let error):
                this.failure(error)
            }
        }
    }
    
    private func requestToken(code code: String, completion: Result<Token, Error> -> Void) {
        var params = [
            "code": code,
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURL.absoluteString,
            "state": state
        ]
        
        additionalParamsForTokenRequest.forEach { params[$0] = String($1) }
        
        HTTP.POST(tokenURL, parameters: params) { result in
            switch result {
            case .Success(let json):
                if let token = Token(json: json) {
                    completion(.Success(token))
                } else {
                    completion(.Failure(Error(json)))
                }
            case .Failure(let error):
                let error = Error(error)
                completion(.Failure(error))
            }
        }
    }
    
    private func success(token: Token) {
        Queue.main { [weak self] in
            guard let this = self else { return }
            
            this.completion?(.Success(token))
            this.safariVC?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func failure(error: Error) {
        Queue.main { [weak self] in
            guard let this = self else { return }
            
            this.completion?(.Failure(error))
            this.safariVC?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func visit(URL URL: NSURL) {
        if #available(iOS 9.0, *) {
            safariVC = SFSafariViewController(URL: URL, delegate: self)
            Application.presentViewController(safariVC!)
        } else {
            NotificationCenter.addObserver(self, selector: #selector(Provider.didBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification)
            Application.openURL(URL)
        }
    }
    
    @objc func didBecomeActive(notification: NSNotification) {
        NotificationCenter.removeObserver(self, name: UIApplicationDidBecomeActiveNotification)
        
        failure(.Cancel)
    }
}

@available(iOS 9.0, *)
extension Provider: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(controller: SFSafariViewController) {
        failure(.Cancel)
    }
}

// MARK: - ShouldHandleOpenURL

extension Provider {
    private func shouldHandleURL(URL: NSURL, options: [String: AnyObject]) -> Bool {
        guard isLegitSourceApplication(options) else {
            return false
        }
        
        return matchingURLs(URL, redirectURL) ? true : false
    }
    
    private func isLegitSourceApplication(options: [String: AnyObject]) -> Bool {
        guard let sourceApplication = options["UIApplicationOpenURLOptionsSourceApplicationKey"] as? String else {
            return false
        }
        
        return ["com.apple.mobilesafari", "com.apple.SafariViewService"].contains(sourceApplication)
    }
    
    private func matchingURLs(a: NSURL, _ b: NSURL) -> Bool {
        return (a.scheme, a.host, a.path) == (b.scheme, b.host, b.path)
    }
}