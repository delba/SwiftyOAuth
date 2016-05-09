//
//  GitHub.swift
//  SwiftyOAuth
//
//  Created by Damien on 09/05/2016.
//  Copyright © 2016 delba. All rights reserved.
//

extension Provider {
    public static func GitHub(clientID clientID: String, clientSecret: String, redirectURL: String) -> Provider {
        return Provider(
            clientID: clientID,
            clientSecret: clientSecret,
            authorizeURL: "https://github.com/login/oauth/authorize",
            tokenURL: "https://github.com/login/oauth/access_token",
            redirectURL: redirectURL
        )
    }
}