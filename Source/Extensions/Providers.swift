//
//  Providers.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

import Foundation

extension Providers {
    public static func GitHub(id id: String, secret: String) -> Provider {
        return Provider(
            id: id,
            secret: secret,
            authorizeURL: NSURL(string: "https://github.com/login/oauth/authorize")!,
            tokenURL: NSURL(string: "https://github.com/login/oauth/access_token")!,
            scope: nil,
            state: nil
        )
    }
    
    public static func Dribbble(id id: String, secret: String) -> Provider {
        return Provider(
            id: id,
            secret: secret,
            authorizeURL: NSURL(string: "https://dribbble.com/oauth/authorize")!,
            tokenURL: NSURL(string: "https://dribbble.com/oauth/token")!,
            scope: nil,
            state: nil
        )
    }
}