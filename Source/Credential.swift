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
    public let refreshToken: String
    
    public let createdAt: NSTimeInterval
    public let expiresIn: NSTimeInterval
    
    public let scope: String
    public let tokenType: String
    
    public var isValid: Bool {
        return !isExpired
    }
    
    public var isExpired: Bool {
        // TODO: check if not expired
        return false
    }
    
    init(dictionary: [String: AnyObject]) {
        accessToken = dictionary["access_token"] as? String // do checker ici
        refreshToken = dictionary["refreshToken"] as? String // do checker ici
    }
}
