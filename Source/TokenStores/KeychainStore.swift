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
        guard let token = token else {
            return
        }

        let key = keyForProvider(provider)

        let data = NSKeyedArchiver.archivedDataWithRootObject(token.dictionary)
   
        let result = Keychain.save(key, data: data)
    }
}