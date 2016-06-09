//
//  TokenStoresTests.swift
//  SwiftyOAuth
//
//  Created by Fabio Milano on 09/06/16.
//  Copyright © 2016 delba. All rights reserved.
//

import XCTest
@testable import SwiftyOAuth

extension Token {
    static func mockToken() -> Token? {
        let information = ["access_token" : "A_TEST_ACCESS_TOKEN",
                           "refresh_token" : "A_TEST_REFRESH_TOKEN",
                           "expires_in" : String(NSDate.timeIntervalSinceDate(NSDate(timeIntervalSinceNow: 3600))),
                           "token_type" : "Bearear"]
        
        return Token(dictionary: information)
    }
}

extension Provider {
    static func mockProvider() -> Provider {
        return Provider(clientID: "testing_client_id", authorizeURL: "testing_authorize_url", redirectURL: "redirect_url")
    }
}

class UserDefaultTokenStoreTests: XCTestCase {
    func testStoreTokenForProvider(){
        let token = Token.mockToken()
        let provider = Provider.mockProvider()
        
        let innerStore = NSUserDefaults.standardUserDefaults()
        let tokenStore = UserDefaultsTokenStore(userDefaults: innerStore)
        
        tokenStore.setToken(token, forProvider: provider)
        
        let savedInformation = innerStore.dictionaryForKey(tokenStore.keyForProvider(provider))
        
        XCTAssertNotNil(savedInformation)
        XCTAssert(savedInformation!["access_token"] as? String == token?.accessToken, "Access token mismatch")
        XCTAssert(savedInformation!["refresh_token"] as? String == token?.refreshToken, "Refresh token mismatch")
        XCTAssert(savedInformation!["expires_in"] as? NSTimeInterval == token?.expiresIn, "expires_in token value mismatch")
        XCTAssert(TokenType(savedInformation!["token_type"]) == token?.tokenType, "Token type mismatch")
    }
    
    func testGetTokenForProvider(){
        let token = Token.mockToken()
        let provider = Provider.mockProvider()
        
        let innerStore = NSUserDefaults.standardUserDefaults()
        let tokenStore = UserDefaultsTokenStore(userDefaults: innerStore)
        
        tokenStore.setToken(token, forProvider: provider)
        
        let savedInformation = tokenStore.getTokenForProvider(provider)
        
        XCTAssertNotNil(savedInformation)
        XCTAssert(savedInformation?.accessToken == token?.accessToken, "Access token mismatch")
        XCTAssert(savedInformation?.refreshToken == token?.refreshToken, "Refresh token mismatch")
        XCTAssert(savedInformation?.expiresIn == token?.expiresIn, "expires_in token value mismatch")
        XCTAssert(savedInformation?.tokenType == token?.tokenType, "Token type mismatch")
    }
}

class UbiquitousKeyValueStoreTests: XCTestCase {
    func testStoreTokenForProvider(){
        let token = Token.mockToken()
        let provider = Provider.mockProvider()
        
        let innerStore = NSUbiquitousKeyValueStore.defaultStore()
        let tokenStore = UbiquitousKeyValueStore(ubiquitousKeyValueStore: innerStore)
        
        tokenStore.setToken(token, forProvider: provider)
        
        let savedInformation = innerStore.dictionaryForKey(tokenStore.keyForProvider(provider))
        
        XCTAssertNotNil(savedInformation)
        XCTAssert(savedInformation!["access_token"] as? String == token?.accessToken, "Access token mismatch")
        XCTAssert(savedInformation!["refresh_token"] as? String == token?.refreshToken, "Refresh token mismatch")
        XCTAssert(savedInformation!["expires_in"] as? NSTimeInterval == token?.expiresIn, "expires_in token value mismatch")
        XCTAssert(TokenType(savedInformation!["token_type"]) == token?.tokenType, "Token type mismatch")
    }
    
    func testGetTokenForProvider(){
        let token = Token.mockToken()
        let provider = Provider.mockProvider()
        let tokenStore = UbiquitousKeyValueStore()
        
        tokenStore.setToken(token, forProvider: provider)
        
        let savedInformation = tokenStore.getTokenForProvider(provider)
        
        XCTAssertNotNil(savedInformation)
        XCTAssert(savedInformation?.accessToken == token?.accessToken, "Access token mismatch")
        XCTAssert(savedInformation?.refreshToken == token?.refreshToken, "Refresh token mismatch")
        XCTAssert(savedInformation?.expiresIn == token?.expiresIn, "expires_in token value mismatch")
        XCTAssert(savedInformation?.tokenType == token?.tokenType, "Token type mismatch")
    }
}


