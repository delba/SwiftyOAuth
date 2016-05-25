//
// ResponseType.swift
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

// MARK: - AuthorizationFlow

internal enum ResponseType {
    case Token
    case Code
    
    var params: [String: String] {
        switch self {
        case .Token:
            return [
                "response_type": "token"
            ]
        case .Code:
            return [
                "response_type": "code"
            ]
        }
    }
}

// MARK: - Client-side (implicit) flow

extension Provider {
    func handleURLForTokenResponseType(URL: NSURL, completion: Result<Token, Error> -> Void) {
        let result: Result<Token, Error>
        
        if let token = Token(dictionary: URL.fragments) {
            self.token = token
            result = .Success(token)
        } else {
            result = .Failure(Error(URL.fragments))
        }
        
        Queue.main { completion(result) }
    }
}

// MARK: - Server-side (explicit) flow

extension Provider {
    func handleURLForCodeResponseType(URL: NSURL, completion: Result<Token, Error> -> Void) {
        guard let code = URL.queries["code"] else {
            let error = Error(URL.queries)
            
            Queue.main { completion(.Failure(error)) }
            
            return
        }
        
        requestToken(.AuthorizationCode(code), completion: completion)
    }
    
    internal func requestToken(grantType: GrantType, completion: Result<Token, Error> -> Void) {
        var params = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURL.absoluteString,
            "state": state
        ]
        
        grantType.params.forEach { params[$0] = $1 }
        
        additionalParamsForTokenRequest.forEach { params[$0] = String($1) }
        
        HTTP.POST(tokenURL!, parameters: params) { resultJSON in
            let result: Result<Token, Error>
            
            switch resultJSON {
            case .Success(let json):
                if let token = Token(dictionary: json) {
                    self.token = token
                    result = .Success(token)
                } else {
                    result = .Failure(Error(json))
                }
            case .Failure(let error):
                result = .Failure(Error(error))
            }
            
            Queue.main { completion(result) }
        }
    }
}