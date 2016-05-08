//
//  SwiftyOAuth.swift
//  SwiftyOAuth
//
//  Created by Damien on 08/05/2016.
//  Copyright © 2016 delba. All rights reserved.
//

public struct SwiftyOAuth {
    public static var redirectURI = "" // "myapp://oauth/callback"
    
    public func handleOpenURL(URL: NSURL) {
        
    }
}

// TODO: see if we can get the app name at runtime
// oui, on peut. Cf. Permission pour preAlert
// CFBundleURLSchemes
