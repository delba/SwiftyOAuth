//
// TokenStoreTests.swift
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

let token: Token? = {
    let dictionary = [
        "access_token": "A_TEST_ACCESS_TOKEN",
        "refresh_token": "A_TEST_REFRESH_TOKEN",
        "expires_in": String(Date().timeIntervalSinceNow),
        "token_type": "Bearer"
    ]
    
    return Token(dictionary: dictionary)
}()

let provider = Provider(clientID: "testing_client_id", authorizeURL: "testing_authorize_url", redirectURL: "redirect_url")

class UserDefaultTokenStoreTests: XCTestCase {
    let store = UserDefaults.standard
    
    func testStoreTokenForProvider(){
        provider.tokenStore = store
        provider.token = token
        
        let savedInformation = store.dictionary(forKey: store.key(forProvider: provider))
        
        XCTAssertNotNil(savedInformation)
        XCTAssertEqual(savedInformation!["access_token"] as? String, provider.token?.accessToken)
        XCTAssertEqual(savedInformation!["refresh_token"] as? String, provider.token?.refreshToken)
        XCTAssertEqual(savedInformation!["expires_in"] as? TimeInterval, provider.token?.expiresIn)
        XCTAssertEqual(TokenType(savedInformation!["token_type"]), provider.token?.tokenType)
    }
}

class UbiquitousKeyValueStoreTests: XCTestCase {
    let store = NSUbiquitousKeyValueStore.default()
    
    func testStoreTokenForProvider(){
        provider.tokenStore = store
        provider.token = token
        
        let savedInformation = store.dictionary(forKey: store.key(forProvider: provider))
        
        XCTAssertNotNil(savedInformation)
        XCTAssertEqual(savedInformation!["access_token"] as? String, provider.token?.accessToken)
        XCTAssertEqual(savedInformation!["refresh_token"] as? String, provider.token?.refreshToken)
        XCTAssertEqual(savedInformation!["expires_in"] as? TimeInterval, provider.token?.expiresIn)
        XCTAssertEqual(TokenType(savedInformation!["token_type"]), provider.token?.tokenType)
    }
}


