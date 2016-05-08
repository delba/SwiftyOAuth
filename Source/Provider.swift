//
//  Provider.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

import Foundation

// TODO: see if we can get the app name at runtime
// oui, on peut. Cf. Permission pour preAlert
// CFBundleURLSchemes

public struct SwiftyOAuth {
    public static var redirectURI = "" // "myapp://oauth/callback"
    
    public func handleOpenURL(URL: NSURL) {
        
    }
}

public class Providers {
    private init() {}
}

public class Provider: Providers {
    public let id: String
    public let secret: String
    public let baseURL: NSURL
    
    public private(set) var credential: Credential?
    
    var completion: (Result -> Void)?
    
    var authorizeURL: NSURL {
        return baseURL.URLByAppendingPathComponent("oauth/authorize").query([
            "response_type": "code",
            "client_id": id,
            "redirect_uri": SwiftyOAuth.redirectURI
        ])!
    }
    
    var tokenURL: NSURL {
        return baseURL.URLByAppendingPathComponent("oauth/token")
    }
    
    public init(id: String, secret: String, baseURL: NSURL) {
        self.id = id
        self.secret = secret
        self.baseURL = baseURL
    }
    
    public func authorize(completion: Result -> Void) {
        self.completion = completion
        
        UIApplication.sharedApplication().openURL(authorizeURL)
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

func test() {
    let twitter: Provider = .Twitter(id: "hello", secret: "secret123")
    
    twitter.authorize { result in
        switch result {
        case .Success(let credential):
            print(credential)
        case .Failure(let error):
            print(error)
        }
    }
}