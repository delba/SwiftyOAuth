//
// Keychain.swift
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

import Security

public struct Keychain {
    
    public static let shared = Keychain()
    
    private init() {}
    
    @discardableResult
    public func set(_ dictionary: [String: Any], forKey key: String) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        
        let query = [
            kSecClass       as String : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData   as String : data
        ] as CFDictionary
        
        SecItemDelete(query)
        
        return SecItemAdd(query, nil) == noErr
    }
    
    public func dictionary(forKey key: String) -> [String: Any]? {
        let query = [
            kSecClass       as String : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData  as String : kCFBooleanTrue,
            kSecMatchLimit  as String : kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        
        let status = withUnsafeMutablePointer(to: &dataTypeRef) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }
        
        guard status == errSecSuccess, let data = dataTypeRef as? Data else { return nil }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: AnyObject]
    }
    
    @discardableResult
    public func removeObject(forKey key: String) -> Bool {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key
        ] as CFDictionary
        
        return SecItemDelete(query) == noErr
    }
    
    @discardableResult
    internal func reset() -> Bool {
        let query = [
            kSecClass as String : kSecClassGenericPassword
        ] as CFDictionary
        
        return SecItemDelete(query) == noErr
    }
}
