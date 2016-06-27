//
// KeychainTests.swift
// Based on Gist: https://gist.github.com/jackreichert/414623731241c95f0e20
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

class KeychainTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Keychain.clear()
    }
    
    override func tearDown() {
        Keychain.clear()
        super.tearDown()
    }
    
    func testSaveLoad() {
        let key1 = "testSaveLoadKey1"
        let key2 = "testSaveLoadKey2"
        
        let dictionary: [String: AnyObject] = [
            "string": "string",
            "bool": true
        ]
        
        XCTAssertTrue(Keychain.load(key1) == nil)
        XCTAssertTrue(Keychain.load(key2) == nil)
        
        XCTAssertTrue(Keychain.save(key1, dictionary: dictionary))
        
        XCTAssertTrue(Keychain.load(key1) != nil)
        XCTAssertTrue(Keychain.load(key2) == nil)
        
        let loadDictionary = Keychain.load(key1)!
        
        XCTAssertEqual("string", loadDictionary["string"] as? String)
        XCTAssertEqual(true, loadDictionary["bool"] as? Bool)
    }
    
    
    func testDelete() {
        let key1 = "testDeleteKey1"
        let key2 = "testDeleteKey2"
        
        let dictionary: [String: AnyObject] = [
            "string": "string",
            "bool": true
        ]
        
        XCTAssertTrue(Keychain.save(key1, dictionary: dictionary))
        XCTAssertTrue(Keychain.save(key2, dictionary: dictionary))
        
        XCTAssertTrue(Keychain.load(key1) != nil)
        XCTAssertTrue(Keychain.load(key2) != nil)
        
        XCTAssertTrue(Keychain.delete(key1))
        
        XCTAssertTrue(Keychain.load(key1) == nil)
        XCTAssertTrue(Keychain.load(key2) != nil)
    }
    
    func testClear() {
        let key = "testClearKey"
        
        let dictionary: [String: AnyObject] = [
            "string": "string",
            "bool": true
        ]
        
        Keychain.save(key, dictionary: dictionary)
        XCTAssertTrue(Keychain.load(key) != nil)
        
        Keychain.clear()
        XCTAssertTrue(Keychain.load(key) == nil)
    }
    
}