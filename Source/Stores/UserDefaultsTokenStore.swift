//
//  UserDefaultsTokenStore.swift
//  SwiftyOAuth
//
//  Created by Fabio Milano on 09/06/16.
//  Copyright © 2016 delba. All rights reserved.
//

import Foundation

public class UserDefaultsTokenStore: TokenStore {
    private let userDefaults: NSUserDefaults
    
    init(userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        self.userDefaults = userDefaults
    }
    
    public func getTokenForProvider(provider: Provider) -> Token? {
        let key = keyForProvider(provider)
        
        guard let dictionary = userDefaults.dictionaryForKey(key) else {
            return nil
        }
        
        return Token(dictionary: dictionary)
    }
    
    public func setToken(token: Token?, forProvider provider: Provider) {
        let key = keyForProvider(provider)
        userDefaults.setObject(token?.dictionary, forKey: key)
    }
}