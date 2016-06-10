//
// Token.swift
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

public struct Token {
    /// The access token.
    public var accessToken: String {
        return dictionary["access_token"] as! String
    }
    
    /// The refresh token.
    public var refreshToken: String? {
        return dictionary["refresh_token"] as? String
    }
    
    /// The remaining lifetime on the access token.
    public var expiresIn: NSTimeInterval? {
        return dictionary["expires_in"] as? NSTimeInterval
    }
    
    /// A boolean value indicating whether the token is expired.
    public var isExpired: Bool {
        guard let expiresIn = expiresIn else {
            return false
        }
        
        return NSDate.timeIntervalSinceReferenceDate() > createdAt + expiresIn
    }
    
    /// A boolean value indicating whether the token is valid.
    public var isValid: Bool {
        return !isExpired
    }
    
    private var createdAt: NSTimeInterval {
        return dictionary["created_at"] as! NSTimeInterval
    }
    
    /// The token type.
    public var tokenType: TokenType? {
        return TokenType(dictionary["token_type"])
    }
    
    /// The scopes.
    public var scopes: [String]? {
        return scope?.componentsSeparatedByString(" ")
    }
    
    /// The scope.
    private var scope: String? {
        return dictionary["scope"] as? String
    }
    
    /// The full response dictionary.
    public let dictionary: [String: AnyObject]
    
    internal init?(dictionary: [String: AnyObject]) {
        guard dictionary["access_token"] as? String != nil else {
            return nil
        }
        
        var dictionary = dictionary
        dictionary["created_at"] = NSDate.timeIntervalSinceReferenceDate()
        
        self.dictionary = dictionary
    }
}

extension NSMutableURLRequest {
    public func setAccessToken(token: Token) -> Void {
        if let type = token.tokenType {
            switch type {
            case TokenType.Bearer:
                self.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
            }
        }
    }
}