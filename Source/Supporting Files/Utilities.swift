//
//  Utilities.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

import Foundation

extension NSURL {
    var queryItems: [NSURLQueryItem] {
        return NSURLComponents(URL: self, resolvingAgainstBaseURL: false)?.queryItems ?? []
    }
    
    func query(items: [String: String]) -> NSURL? {
        let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false)
        
        components?.queryItems = items.map { name, value in
            return NSURLQueryItem(name: name, value: value)
        }
        
        return components?.URL
    }
    
    @nonobjc func query(name: String) -> String? {
        for item in queryItems where item.name == name {
            return item.value
        }
        
        return nil
    }
}