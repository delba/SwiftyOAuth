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
    
    public var additionalParamsForAuthorization:  [String: String] = [:]
    public var additionalParamsForTokenRequest: [String: String] = [:]
    
    // Only useful if we store the credential in UserDefaults/Keychain
    // Rename Credential to Token ?
    // Yes, we'll store. Otherwise, calling refreshToken won't work.
    // Make it a computed variable
    public private(set) var credential: Credential?
    
    private var safariVC: UIViewController?
    
    public var completion: (Result<Credential, NSError> -> Void)?
    
    public init(clientID: String, clientSecret: String, authorizeURL: String, tokenURL: String, redirectURL: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.authorizeURL = NSURL(string: authorizeURL)!
        self.tokenURL = NSURL(string: tokenURL)!
        self.redirectURL = NSURL(string: redirectURL)!
    }
    
    public func authorize(completion: Result<Credential, NSError> -> Void) {
        self.completion = completion
        
        var params = additionalParamsForAuthorization
        
        params["client_id"] = clientID
        params["redirect_uri"] = redirectURL.absoluteString
        params["scope"] = scope
        params["state"] = state
        
        visit(URL: authorizeURL.query(params))
    }
    
    public func handleURL(URL: NSURL, options: [String: AnyObject]) {
        guard shouldHandleURL(URL, options: options) else { return }
        
        guard let code = URL.query("code") else {
            // let error = extract(error: URL)
            // TODO: extract error if any
            // failure(.Error(fromQueryString: URL.query))
            return // TODO: Call completion with error
        }
        
        // It should be requestCredential unless we rename it to token
        requestToken(code: code) { result in
            switch result {
            case .Success(let credential):
                self.success(credential)
            case .Failure(let error):
                self.failure(error)
            }
        }
    }
    
    private func success(credential: Credential) {
        completion?(.Success(credential))
        
        safariVC?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func failure(error: NSError) {
        completion?(.Failure(error))
        
        safariVC?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func requestToken(code code: String, completion: Result<Credential, NSError> -> Void) {
        var params = additionalParamsForTokenRequest
        
        params["code"] = code
        params["client_id"] = clientID
        params["client_secret"] = clientSecret
        params["redirect_uri"] = redirectURL.absoluteString
        params["state"] = state
        
        HTTP.POST(tokenURL, parameters: params) { result in
            switch result {
            case .Success(let json):
                if let credential = Credential(json: json) {
                    completion(.Success(credential))
                } else {
                    let error = NSError(domain: "Cannot create Credential from JSON \(json)", code: 42, userInfo: json)
                    completion(.Failure(error))
                }
            case .Failure(let error):
                completion(.Failure(error))
            }
        }
    }
    
    private func visit(URL URL: NSURL) {
        if #available(iOS 9.0, *) {
            safariVC = SFSafariViewController(URL: URL, delegate: self)
            Application.presentViewController(safariVC!)
        } else {
            // TODO: add observer ? hmmm maybe not if we explicitly call handleOpenURL()
            Application.openURL(URL)
            // yes but what about the cancel? -> if the user comes back to our app from safari
        }
    }
}

@available(iOS 9.0, *)
extension Provider: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(controller: SFSafariViewController) {
        print("safari view controller did finish")
        let error = NSError(domain: "Cancel authentication (close browser)", code: 42, userInfo: nil)
        failure(error)
    }
}

// MARK: - ShouldHandleOpenURL

extension Provider {
    private func shouldHandleURL(URL: NSURL, options: [String: AnyObject]) -> Bool {
        guard sourceApplication(options) == "com.apple.SafariViewService" else {
            return false
        }
        
        return matchingURLs(URL, redirectURL) ? true : false
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