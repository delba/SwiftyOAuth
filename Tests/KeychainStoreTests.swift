//
//  KeychainStoreTests.swift
//

import Foundation
import XCTest

@testable import SwiftyOAuth

class KeychainStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Keychain.clear()
    }
    
    override func tearDown() {
        Keychain.clear()
        super.tearDown()
    }

    func testSaveLoadTokenFromKeychainStore() {
        let keychainStore = KeychainStore()
        
        let initialToken = keychainStore.getTokenForProvider(provider)
        XCTAssertNil(initialToken, "Initial loaded Token should be nil.")
        
        keychainStore.setToken(token, forProvider: provider)
        let loadedToken = keychainStore.getTokenForProvider(provider)
        XCTAssertNotNil(loadedToken, "Loaded Token should not be nil.")
        
        XCTAssertTrue(token?.accessToken == loadedToken?.accessToken, "Access token should match the initial value.")
        XCTAssertTrue(token?.refreshToken == loadedToken?.refreshToken, "Refresh token should match the initial value.")
        XCTAssertTrue(token?.expiresIn == loadedToken?.expiresIn, "Expiration date should match the initial value.")
        XCTAssertTrue(token?.tokenType == loadedToken?.tokenType, "Token type should match the initial value.")
    }
    
    
}