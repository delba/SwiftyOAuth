//
// Error.swift
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

public enum Error: Swift.Error {
    /// The user cancelled the authorization process by closing the web browser window.
    case cancel
    
    /// The OAuth application has been suspended.
    case applicationSuspended(String)
    
    /// The provided redirectURL that doesn't match the one registered with the OAuth application.
    case redirectURIMismatch(String)
    
    /// The user denied access.
    case accessDenied(String)
    
    /// Some required parameters were not provided.
    case invalidRequest(String)
    
    /// The scope parameter provided is not a valid subset of scopes.
    case invalidScope(String)
    
    /// The passed `clientID` and/or `clientSecret` are incorrect.
    case invalidClient(String)
    
    /// The verification code is incorrect or expired.
    case invalidGrant(String)
    
    /// The server returned an unknown error.
    case serverError(String)
    
    /// The endpoint is temporarily unable to respond.
    case temporarilyUnavailable(String)
    
    /// The application responded with an error that doesn't match any enum cases.
    case other(String, String)
    
    /// The application emitted a response which format doesn't match a success one nor an error one.
    case unknown([String: Any])
    
    /// An error trigger when making network requests or parsing JSON.
    case nsError(Foundation.NSError)
    
    init(_ dictionary: [String: Any]) {
        guard let error = dictionary["error"] as? String,
            let description = dictionary["error_description"] as? String
            else { self = .unknown(dictionary); return }
        
        switch error {
        case "application_suspended":
            self = .applicationSuspended(description)
        case "redirect_uri_mismatch":
            self = .redirectURIMismatch(description)
        case "access_denied":
            self = .accessDenied(description)
        case "invalid_request":
            self = .invalidRequest(description)
        case "invalid_scope":
            self = .invalidScope(description)
        case "invalid_client", "incorrect_client_credentials":
            self = .invalidClient(description)
        case "invalid_grant", "bad_verification_code":
            self = .invalidGrant(description)
        case "server_error":
            self = .serverError(description)
        case "temporarily_unavailable":
            self = .temporarilyUnavailable(description)
        default:
            self = .other(error, description)
        }
    }
    
    init(_ error: NSError) {
        self = .nsError(error)
    }
}
