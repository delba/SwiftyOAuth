//
//  Providers.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

import Foundation

extension Providers {
    public static func Twitter(id id: String, secret: String) -> Provider {
        return Provider(
            id: id,
            secret: secret,
            baseURL: NSURL(string: "")!
        )
    }
}