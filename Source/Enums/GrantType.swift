//
// GrantType.swift
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

internal enum GrantType {
    case authorizationCode(String)
    case refreshToken(String)
    case clientCredentials
    case password(user: String, pass: String)

    var params: [String: String] {
        switch self {
        case .authorizationCode(let code):
            return [
                "grant_type": "authorization_code",
                "code": code
            ]
        case .refreshToken(let token):
            return [
                "grant_type": "refresh_token",
                "refresh_token": token
            ]
        case .clientCredentials:
            return [
                "grant_type": "client_credentials"
            ]
        case .password(let user, let pass):
            return [
                "grant_type": "password",
                "username": user,
                "password": pass
            ]
        }
    }
}
