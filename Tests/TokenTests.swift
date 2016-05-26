//
// TokenTests.swift
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

class TokenTests: XCTestCase {
    func testInit() {
        let dictionary: [String: AnyObject] = [
            "access_token": "accessToken",
            "scope": "first second"
        ]
        
        let token = Token(dictionary: dictionary)
        
        XCTAssertNotNil(token)
        XCTAssertEqual("accessToken", token?.accessToken)
        XCTAssertNotNil(token?.scopes)
        XCTAssertEqual(["first", "second"], token!.scopes!)
    }
    
    func testFailableInit() {
        let dictionary: [String: AnyObject] = [
            "token_type": "tokenType",
            "scope": "scope"
        ]
        
        let token = Token(dictionary: dictionary)
        
        XCTAssertNil(token)
    }
    
    func testTokenType() {
        var dictionary: [String: AnyObject]
        
        dictionary = [
            "token_type": "bearer"
        ]
        
        XCTAssert(TokenType(dictionary["token_type"]) == .Bearer)
        
        dictionary = [
            "token_type": "Bearer"
        ]
        
        XCTAssert(TokenType(dictionary["token_type"]) == .Bearer)
        
        dictionary = [
            "token_type": "other"
        ]
        
        XCTAssertNil(TokenType(dictionary["token_type"]))
        
        dictionary = [:]
        
        XCTAssertNil(TokenType(dictionary["token_type"]))
    }
}