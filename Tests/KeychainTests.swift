//
//  KeychainTests.swift
//
//  Based on Gist: https://gist.github.com/jackreichert/414623731241c95f0e20
//

import Foundation

import UIKit
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
        let saveData = "data".dataValue
        
        XCTAssertTrue(Keychain.load(key1) == nil)
        XCTAssertTrue(Keychain.load(key2) == nil)
        
        XCTAssertTrue(Keychain.save(key1, data: saveData))
        
        XCTAssertTrue(Keychain.load(key1) != nil)
        XCTAssertTrue(Keychain.load(key2) == nil)
        
        let loadData = Keychain.load(key1)!
        
        XCTAssertEqual(loadData.stringValue, saveData.stringValue)
    }
    
    
    func testDelete() {
        let key1 = "testDeleteKey1"
        let key2 = "testDeleteKey2"
        let saveData = "testDeleteData".dataValue
        
        XCTAssertTrue(Keychain.save(key1, data: saveData))
        XCTAssertTrue(Keychain.save(key2, data: saveData))
        
        XCTAssertTrue(Keychain.load(key1) != nil)
        XCTAssertTrue(Keychain.load(key2) != nil)
        
        XCTAssertTrue(Keychain.delete(key1))
        
        XCTAssertTrue(Keychain.load(key1) == nil)
        XCTAssertTrue(Keychain.load(key2) != nil)
    }
    
    func testClear() {
        let key = "testClearKey"
        let data = "testClearData".dataValue
        
        Keychain.save(key, data: data)
        XCTAssertTrue(Keychain.load(key) != nil)
        
        Keychain.clear()
        XCTAssertTrue(Keychain.load(key) == nil)
    }
    
}

extension String {
    public var dataValue: NSData {
        return dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
}

extension NSData {
    public var stringValue: String {
        return NSString(data: self, encoding: NSUTF8StringEncoding)! as String
    }
}