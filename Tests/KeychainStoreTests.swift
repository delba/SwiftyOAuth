//
// KeychainStoreTests.swift
//
// Copyright (c) 2016 Damien (http://delba.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

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
    
    func testDeleteTokenFromKeychainStore() {
        let keychainStore = KeychainStore()
        
        keychainStore.setToken(token, forProvider: provider)
        var loadedToken = keychainStore.getTokenForProvider(provider)
        XCTAssertNotNil(loadedToken, "Loaded Token should not be nil.")
        
        keychainStore.setToken(nil, forProvider: provider)
        loadedToken = keychainStore.getTokenForProvider(provider)
        XCTAssertNil(loadedToken, "Loaded Token should not be nil.")
    }
    
    
}