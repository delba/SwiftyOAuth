//
//  Provider.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

public class Provider: Providers {
    public let clientID: String
    public let clientSecret: String
    
    public let authorizeURL: NSURL
    public let tokenURL: NSURL
    public let redirectURL: NSURL
    
    public var scope: String?
    public var state: String?
    
    public private(set) var credential: Credential?
    
    public var completion: (Result -> Void)?
    
    public init(clientID: String, clientSecret: String, authorizeURL: NSURL, tokenURL: NSURL, redirectURL: NSURL) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.authorizeURL = authorizeURL
        self.tokenURL = tokenURL
        self.redirectURL = redirectURL
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
            // TODO: Present SFSafariViewController
        } else {
            UIApplication.sharedApplication().openURL(URL)
        }
    }
    
    public func handleOpenURL(URL: NSURL) {
        guard URL.host == "oauth" && URL.path == "/callback" else { return }
        // TODO: check against redirectURL
        // TODO: check against safari.webservice or something like that
        
        guard let code = URL.query("code") else {
            return // TODO: Call completion with error
        }
        
        guard let completion = completion else {
            return // TODO: do better than that
        }
        
        exchangeCodeForToken(code, completion: completion)
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
    
    func refreshToken(completion: Result -> Void) {
    }
}