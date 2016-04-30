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

// TODO: Store Token in the keychain
// Keychain(key: "swifty-oauth.http://twitter.com/")
// key => Provider.baseURL.absoluteString

public struct Token {
    public let accessToken: String
    public let tokenType: String
    public let scope: String
    public let dictionary: [String: AnyObject]
    
    init?(json: JSON) {
        guard let
            accessToken = json["access_token"] as? String,
            tokenType = json["token_type"] as? String,
            scope = json["scope"] as? String
        else { return nil }
        
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.scope = scope
        
        self.dictionary = json
    }
}