//
//  Utilities.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

internal let Application = UIApplication.sharedApplication()

extension UIApplication {
    var rootViewController: UIViewController? {
        let root = delegate?.window??.rootViewController
        return root?.presentedViewController ?? root // Handle presenting an alert over a modal screen
    }
    
    func presentViewController(viewController: UIViewController) {
        rootViewController?.presentViewController(viewController, animated: true, completion: nil)
    }
}

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

@available(iOS 9.0, *)
extension SFSafariViewController {
    convenience init(URL: NSURL, delegate: SFSafariViewControllerDelegate) {
        self.init(URL: URL)
        self.delegate = delegate
    }
}