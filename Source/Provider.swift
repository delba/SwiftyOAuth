//
//  Provider.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

import SafariServices

public class Provider: NSObject {
    public let clientID: String
    public let clientSecret: String
    
    public let authorizeURL: NSURL
    public let tokenURL: NSURL
    public let redirectURL: NSURL
    
    public var scope: String?
    public var state: String?
    
    public private(set) var credential: Credential?
    
    private var safariVC: UIViewController?
    
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
        
        let URL = authorizeURL.query([
            "client_id": clientID,
            "redirect_uri": redirectURL.absoluteString,
            "scope": scope,
            "state": state
        ])
        
        if #available(iOS 9.0, *) {
            safariVC = SFSafariViewController(URL: URL, delegate: self)
            Application.presentViewController(safariVC!)
        } else {
            Application.openURL(URL)
        }
    }
    
    public func handleOpenURL(URL: NSURL, options: [String: AnyObject]) {
        guard shouldHandleOpenURL(URL, options: options) else { return }
        
        print(URL)
        
        // TODO: guard let error = URL.query("error")
        
        guard let code = URL.query("code") else {
            print("no code")
            return // TODO: Call completion with error
        }
        
        print("code", code)
        
        guard let completion = completion else {
            return // TODO: do better than that
        }
        
        if #available(iOS 9.0, *) {
            dismissSafariVC()
        }
        
        exchangeCodeForToken(code, completion: completion)
    }
    
    public func refreshToken(completion: Result -> Void) {
    }
    
    private func exchangeCodeForToken(code: String, completion: Result -> Void) {
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
}

@available(iOS 9.0, *)
extension Provider: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(controller: SFSafariViewController) {
        print("safari view controller did finish")
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
    private func shouldHandleOpenURL(URL: NSURL, options: [String: AnyObject]) -> Bool {
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