//
// SwiftyOAuthTests.swift
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
import OHHTTPStubs
@testable import SwiftyOAuth

class SwiftyOAuthTests: XCTestCase {
    let bundle = NSBundle(forClass: SwiftyOAuthTests.self)
    
    let token: Token? = {
        let dictionary = [
            "access_token": "THE_STUB_ACCESS_TOKEN",
            "refresh_token": "THE_STUB_REFRESH_TOKEN",
            "expires_in": NSDate().timeIntervalSinceNow + 3600,
            "token_type": "Bearer"
        ]
        
        return Token(dictionary: dictionary as! [String : AnyObject])
    }()
    
    let expiredToken: Token? = {
        let dictionary = [
            "access_token": "THE_STUB_ACCESS_TOKEN",
            "refresh_token": "THE_STUB_REFRESH_TOKEN",
            "expires_in": -10,
            "created_at": NSDate().timeIntervalSinceReferenceDate,
            "token_type": "Bearer"
        ]
        
        return Token(dictionary: dictionary as! [String : AnyObject])
    }()
}
