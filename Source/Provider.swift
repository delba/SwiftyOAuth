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
    // Yes, we'll store. Otherwise, calling refreshToken won't work.
    // Make it a computed variable
    public private(set) var credential: Credential?
    
    private var safariVC: UIViewController?
    
    // TODO: when call completion, dismiss safariVC
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
        // Should be called whenever we call `completion(_:)`
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
        
        // It should be requestCredential unless we rename it to token
        requestToken(code: code) { result in
            switch result {
            case .Success(let credential):
                self.completion?(.Success(credential))
            case .Failure(let error):
                self.completion?(.Failure(error))
            }
        }
    }
    
    public func refreshToken(completion: Result<Credential, NSError> -> Void) {
    }
    
    private func requestToken(code code: String, completion: Result<Credential, NSError> -> Void) {
        // Do something like visit(URL:) ?
        
        let params = [
            "code": code,
            "redirect_uri": redirectURL.absoluteString,
            "client_id": clientID,
            "client_secret": clientSecret
        ]
        
        HTTP.POST(tokenURL, parameters: params) { result in
            switch result {
            case .Success(let json):
                if let credential = Credential(json: json) {
                    print("success", credential)
                    completion(.Success(credential))
                } else {
                    print("error", json)
                    let error = NSError(domain: "can't parse json", code: 42, userInfo: json)
                    completion(.Failure(error))
                }
            case .Failure(let error):
                print("Error", error)
                completion(.Failure(error))
            }
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
            // yes but what about the cancel? -> if the user comes back to our app from safari
        }
    }
    
    // Extract this in Utilities
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