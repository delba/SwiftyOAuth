//
// Keychain.swift
//
// Copyright (c) 2016 Damien (http://delba.io)
// Based on Gist: https://gist.github.com/jackreichert/414623731241c95f0e20
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
    public static func save(key: String, dictionary: [String: AnyObject]) -> Bool {
        let data = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
        
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data
        ]
        
        SecItemDelete(query)
        
        let status: OSStatus = SecItemAdd(query, nil)
        
        return status == noErr
    }
    
    public static func load(key: String) -> [String: AnyObject]? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        
        let status = withUnsafeMutablePointer(&dataTypeRef) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }
        
        guard status == errSecSuccess, let data = dataTypeRef as? NSData else { return nil }
        
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: AnyObject]
    }
    
    public static func delete(key: String) -> Bool {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key
        ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        
        return status == noErr
    }
    
    internal static func clear() -> Bool {
        let query = [
            kSecClass as String : kSecClassGenericPassword
        ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        
        return status == noErr
    }
}