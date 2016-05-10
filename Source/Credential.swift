//
//  Credential.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

// TODO: Store credential in the keychain
// Keychain(key: "swifty-oauth.http://twitter.com/")
// key => Provider.baseURL.absoluteString

public struct Credential {
    public let accessToken:  String
    public let tokenType: String
    public let scope: String
    
    init?(json: [String: AnyObject]) {
        guard let
            accessToken = json["access_token"] as? String,
            tokenType = json["token_type"] as? String,
            scope = json["scope"] as? String
        else { return nil }
        
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.scope = scope
    }
}
