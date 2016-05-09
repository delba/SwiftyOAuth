//
//  Provider.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

public class Provider: NSObject {
    public let clientID: String
    public let clientSecret: String
    
    public let authorizeURL: NSURL
    public let tokenURL: NSURL
    public let redirectURL: NSURL
    
    public var scope: String?
    public var state: String?
    
    // Only useful if we store the credential in UserDefaults/Keychain
    // Rename Credential to Token ?
    public private(set) var credential: Credential?
    
    private var safariVC: UIViewController?
    
    // TODO: when call completion, dismiss safariVC
    public var completion: (Result -> Void)?
    
    public init(clientID: String, clientSecret: String, authorizeURL: String, tokenURL: String, redirectURL: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.authorizeURL = NSURL(string: authorizeURL)!
        self.tokenURL = NSURL(string: tokenURL)!
        self.redirectURL = NSURL(string: redirectURL)!
    }
    
    public func authorize(completion: Result -> Void) {
        self.completion = completion
        
        visit(URL: authorizeURL.query([
            "client_id": clientID,
            "redirect_uri": redirectURL.absoluteString,
            "scope": scope,
            "state": state
        ]))
    }
    
    public func handleURL(URL: NSURL, options: [String: AnyObject]) {
        guard shouldHandleURL(URL, options: options) else { return }
        
        // Interesting but should also be called for cancel...
        defer {
            safariVC?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        // Extract code
        // guard let code = extract(code: URL)
        guard let code = URL.query("code") else {
            // let error = extract(error: URL)
            // TODO: extract error if any
            // failure(.Error(fromQueryString: URL.query))
            return // TODO: Call completion with error
        }
        
        requestToken(code: code) { result in
            switch result {
            case .Success(let credential):
                self.completion?(.Success(credential))
            case .Failure(let error):
                self.completion?(.Failure(error))
            }
        }
    }
    
    public func refreshToken(completion: Result -> Void) {
    }
    
    private func requestToken(code code: String, completion: Result -> Void) {
        let parameters = [
            "code": code,
            "redirect_uri": redirectURL.absoluteString
        ]
        
        HTTP.POST(tokenURL, parameters: parameters) { response in
            // Create a Result enum (either Success or Failure)
            // if success: set self.credentials
            // call completion with result
        }
    }
    
    private func visit(URL URL: NSURL) {
        if #available(iOS 9.0, *) {
            safariVC = SFSafariViewController(URL: URL, delegate: self)
            Application.presentViewController(safariVC!)
        } else {
            // TODO: add observer ? hmmm maybe not if we explicitly call handleOpenURL()
            Application.openURL(URL)
        }
    }
}

@available(iOS 9.0, *)
extension Provider: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(controller: SFSafariViewController) {
        print("safari view controller did finish")
        // THIS IS CANCEL
        dismissSafariVC()
        // Do you really have to dimiss it?
        // call completion
        // controller.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func dismissSafariVC() {
        safariVC?.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - ShouldHandleOpenURL

extension Provider {
    private func shouldHandleURL(URL: NSURL, options: [String: AnyObject]) -> Bool {
        guard sourceApplication(options) == "com.apple.SafariViewService" else {
            return false
        }
        
        guard matchingURLs(URL, redirectURL) else {
            return false
        }
        
        return true
    }
    
    private func sourceApplication(options: [String: AnyObject]) -> String? {
        return options["UIApplicationOpenURLOptionsSourceApplicationKey"] as? String
    }
    
    private func matchingURLs(a: NSURL, _ b: NSURL) -> Bool {
        return (a.scheme, a.host, a.path) == (b.scheme, b.host, b.path)
    }
}

func == <T: Equatable>(tuple1: (T?, T?, T?), tuple2: (T?, T?, T?)) -> Bool {
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1) && (tuple1.2 == tuple2.2)
}