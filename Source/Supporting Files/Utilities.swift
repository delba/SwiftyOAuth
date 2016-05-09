//
//  Utilities.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

struct HTTP {
    static func POST(URL: NSURL, parameters: [String: String]? = nil, completion: NSHTTPURLResponse -> Void) {
        
    }
}

extension NSURL {
    var queryItems: [NSURLQueryItem] {
        return NSURLComponents(URL: self, resolvingAgainstBaseURL: false)?.queryItems ?? []
    }
    
    func query(items: [String: String?]) -> NSURL {
        let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false)
        
        components?.queryItems = items.flatMap { name, value in
            guard let value = value else { return nil }
            
            return NSURLQueryItem(name: name, value: value)
        }
        
        return components?.URL ?? self
    }
    
    @nonobjc func query(name: String) -> String? {
        for item in queryItems where item.name == name {
            return item.value
        }
        
        return nil
    }
}

extension UIApplication {
    func visit(URL: NSURL) {
        
    }
}