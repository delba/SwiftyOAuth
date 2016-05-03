//
//  Credential.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

import Foundation

// TODO: Store credential in the keychain
// Keychain(key: "swifty-oauth.http://twitter.com/")
// key => Provider.baseURL.absoluteString

public struct Credential {
    let accessToken:  String
    let refreshToken: String
    
    let createdAt: NSTimeInterval
    let expiresIn: NSTimeInterval
    
    let scope: String
    let tokenType: String
}