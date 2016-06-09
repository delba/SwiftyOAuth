//
//  UbiquitousKeyValueTokenStore.swift
//  SwiftyOAuth
//
//  Created by Fabio Milano on 09/06/16.
//  Copyright © 2016 delba. All rights reserved.
//

import Foundation

public class UbiquitousKeyValueStore: TokenStore {
    private let ubiquitousKeyValueStore: NSUbiquitousKeyValueStore
    
    init(ubiquitousKeyValueStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()) {
        self.ubiquitousKeyValueStore = ubiquitousKeyValueStore
    }
    
    public func getTokenForProvider(provider: Provider) -> Token? {
        // Before reading the information from the iCloud Key Value store it is important to synchronize cached information with -synchronize
        ubiquitousKeyValueStore.synchronize()
        
        let key = keyForProvider(provider)
        
        guard let dictionary = ubiquitousKeyValueStore.dictionaryForKey(key) else {
            return nil
        }
        
        return Token(dictionary: dictionary)
    }
    
    public func setToken(token: Token?, forProvider provider: Provider) {
        let key = keyForProvider(provider)
        ubiquitousKeyValueStore.setObject(token?.dictionary, forKey: key)
        
        // Make sure that changes are pushed to the iCloud Key Value Store Container.
        ubiquitousKeyValueStore.synchronize()
    }
}