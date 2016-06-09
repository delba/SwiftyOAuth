//
//  TokenStore.swift
//  SwiftyOAuth
//
//  Created by Fabio Milano on 09/06/16.
//  Copyright © 2016 delba. All rights reserved.
//

import Foundation

/**
 *  Define the contract for objects that are designated to store a `Token` struct.
 */
public protocol TokenStore {
    /**
     Retrieve a token for the in input Provider
     
     - parameter provider: The provider requesting the `Token`.
     
     - returns: Optional `Token`
     */
    func getTokenForProvider(provider: Provider) -> Token?
    
    /**
     Store a token for a Provider
    
     - parameter token:   The `Token` to store.
     - parameter service: The provider requesting the `Token` storage.
     
     - returns: Void
     */
    func setToken(token: Token?, forProvider provider: Provider)
}

extension TokenStore {
    internal func keyForProvider(provider: Provider) -> String {
        return "io.delba.SwiftyOAuth.\(provider.authorizeURL.absoluteString)"
    }
}
