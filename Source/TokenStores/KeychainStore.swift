//
//  KeychainStore.swift
//
//

import Foundation

class KeychainStore: TokenStore {
    
    func getTokenForProvider(provider: Provider) -> Token? {
        let key = keyForProvider(provider)
        
        guard let data = Keychain.load(key),
            dictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: AnyObject]
            else { return nil }

        return Token(dictionary: dictionary)
    }
    
    func setToken(token: Token?, forProvider provider: Provider) {
        let key = keyForProvider(provider)
        
        if let token = token {
            let data = NSKeyedArchiver.archivedDataWithRootObject(token.dictionary)
            Keychain.save(key, data: data)
        } else {
            Keychain.delete(key)
        }
    }
}