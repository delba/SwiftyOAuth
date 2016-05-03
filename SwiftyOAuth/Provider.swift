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
    public let strategy: Strategy
    
    public private(set) var credential: Credential?
    
    var completion: (Response -> Void)?
    
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
    
    public init(id: String, secret: String, baseURL: NSURL, strategy: Strategy) {
        self.id = id
        self.secret = secret
        self.baseURL = baseURL
        self.strategy = strategy
    }
    
    public func authorize(completion: Response -> Void) {
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
        
        exchangeCodeForToken(code) { response in
            switch response.result {
            case .Success(let credential):
                print(credential)
                break
            case .Failure(let error):
                print(error)
                break
            }
        }
    }
    
    private func exchangeCodeForToken(code: String, completion: Response -> Void) {
        let parameters = [
            "code": code,
            "redirect_uri": SwiftyOAuth.redirectURI
        ]
        
        HTTP.POST(tokenURL, parameters: parameters, completion: completion)
    }
    
    func refreshToken(completion: Response -> Void) {
    }
}

func test() {
    let twitter: Provider = .Twitter(id: "hello", secret: "secret123")
    
    twitter.authorize { response in
        switch response.result {
        case .Success(let credential):
            print(credential)
        case .Failure(let error):
            print(error)
        }
    }
}