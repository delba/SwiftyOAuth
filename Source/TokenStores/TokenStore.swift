//
// TokenStore.swift
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

public protocol TokenStore {
    /**
     Retrieve a token for the given Provider
     
     - parameter provider: The provider requesting the `Token`.
     
     - returns: Optional `Token`
     */
    func token(forProvider provider: Provider) -> Token?
    
    /**
     Store a token for a Provider
    
     - parameter token:   The `Token` to store.
     - parameter service: The provider requesting the `Token` storage.
     
     - returns: Void
     */
    func set(_ token: Token?, forProvider provider: Provider)
}

internal extension TokenStore {
    func key(forProvider provider: Provider) -> String {
        return "io.delba.SwiftyOAuth.\(provider.clientID)"
    }
}
