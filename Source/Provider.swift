//
//  Provider.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

public class Providers {
    private init() {}
}

public class Provider: Providers {
    public let id: String
    public let secret: String
    
    var authorizeURL: NSURL
    var tokenURL: NSURL
    
    var scope: String?
    var state: String?
    
    public private(set) var credential: Credential?
    
    var completion: (Result -> Void)?
    
    // var tokenURL: NSURL {
    //     return baseURL.URLByAppendingPathComponent("oauth/token")
    // }
    
    public init(id: String, secret: String, authorizeURL: NSURL, tokenURL: NSURL, scope: String?, state: String?) {
        self.id = id
        self.secret = secret
        self.authorizeURL = authorizeURL
        self.tokenURL = tokenURL
        self.scope = scope
        self.state = state
    }
    
    public func authorize(completion: Result -> Void) {
        self.completion = completion
        
        UIApplication.sharedApplication().openURL(authorizeURL.query([
            "client_id": id,
            "redirect_uri": SwiftyOAuth.redirectURI,
            "scope": scope,
            "state": state
        ]))
        // TODO: Present SFSafariViewController
    }
    
    public func handleOpenURL(URL: NSURL) {
        guard URL.host == "oauth" && URL.path == "/callback" else { return }
        // TODO: check against safari.webservice or something like that
        
        guard let code = URL.query("code") else {
            return // TODO: Call completion with error
        }
        
        exchangeCodeForToken(code) { result in
            switch result {
            case .Success(let credential):
                print(credential)
                break
            case .Failure(let error):
                print(error)
                break
            }
        }
    }
    
    private func exchangeCodeForToken(code: String, completion: Result -> Void) {
        let parameters = [
            "code": code,
            "redirect_uri": SwiftyOAuth.redirectURI
        ]
        
        HTTP.POST(tokenURL, parameters: parameters) { response in
            // Create a Result enum (either Success or Failure)
            // call completion with result
        }
    }
    
    func refreshToken(completion: Result -> Void) {
    }
}