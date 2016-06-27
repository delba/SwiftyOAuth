//
//  KeychainStore.swift
//
//

import Foundation

class KeychainStore: TokenStore {
    
    func getTokenForProvider(provider: Provider) -> Token? {
        let key = keyForProvider(provider)

        let data = Keychain.load(key)
        guard let loadedData = data else {
            return nil
        }
        
        let tokenData = NSKeyedUnarchiver.unarchiveObjectWithData(loadedData) as? [String : AnyObject]
        guard let tokenDictionary = tokenData else {
            return nil
        }
        
        let token = Token(dictionary: tokenDictionary)
        return token
    }
    
    func setToken(token: Token?, forProvider provider: Provider) {
        guard let token = token else {
            return
        }

        let key = keyForProvider(provider)

        let data = NSKeyedArchiver.archivedDataWithRootObject(token.dictionary)
   
        let result = Keychain.save(key, data: data)
    }
    
    func keyForProvider(provider: Provider) -> String {
        return "io.delba.SwiftyOAuth.\(provider.clientID)"
    }
    
}