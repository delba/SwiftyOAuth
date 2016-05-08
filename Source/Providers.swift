//
//  Providers.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

public class Providers {
    internal init() {}
}

extension Providers {
    public static func GitHub(clientID clientID: String, clientSecret: String, redirectURL: NSURL) -> Provider {
        return Provider(
            clientID: clientID,
            clientSecret: clientSecret,
            authorizeURL: NSURL(string: "https://github.com/login/oauth/authorize")!,
            tokenURL: NSURL(string: "https://github.com/login/oauth/access_token")!,
            redirectURL: redirectURL
        )
    }
    
    public static func Dribbble(clientID clientID: String, clientSecret: String, redirectURL: NSURL) -> Provider {
        return Provider(
            clientID: clientID,
            clientSecret: clientSecret,
            authorizeURL: NSURL(string: "https://dribbble.com/oauth/authorize")!,
            tokenURL: NSURL(string: "https://dribbble.com/oauth/token")!,
            redirectURL: redirectURL
        )
    }
}