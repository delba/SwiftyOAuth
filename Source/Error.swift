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

public enum Error: ErrorType {
    /// The user cancelled the authorization process by closing the web browser window.
    case Cancel
    
    /// The OAuth application has been suspended.
    case ApplicationSuspended(String)
    
    /// The provided redirectURL that doesn't match the one registered with the OAuth application.
    case RedirectURIMismatch(String)
    
    /// The user denied access.
    case AccessDenied(String)
    
    /// Some required parameters were not provided.
    case InvalidRequest(String)
    
    /// The scope parameter provided is not a valid subset of scopes.
    case InvalidScope(String)
    
    /// The passed `clientID` and/or `clientSecret` are incorrect.
    case InvalidClient(String)
    
    /// The verification code is incorrect or expired.
    case InvalidGrant(String)
    
    /// The server returned an unknown error.
    case ServerError(String)
    
    /// The endpoint is temporarily unable to respond.
    case TemporarilyUnavailable(String)
    
    /// The application responded with an error that doesn't match any enum cases.
    case Other(String, String)
    
    /// The application emitted a response which format doesn't match a success one nor an error one.
    case Unknown([String: AnyObject])
    
    /// An error trigger when making network requests or parsing JSON.
    case NSError(Foundation.NSError)
    
    init(_ dictionary: [String: AnyObject]) {
        guard let error = dictionary["error"] as? String, description = dictionary["error_description"] as? String else {
            self = .Unknown(dictionary)
            return
        }
        
        switch error {
        case "application_suspended":
            self = .ApplicationSuspended(description)
        case "redirect_uri_mismatch":
            self = .RedirectURIMismatch(description)
        case "access_denied":
            self = .AccessDenied(description)
        case "invalid_request":
            self = .InvalidRequest(description)
        case "invalid_scope":
            self = .InvalidScope(description)
        case "invalid_client", "incorrect_client_credentials":
            self = .InvalidClient(description)
        case "invalid_grant", "bad_verification_code":
            self = .InvalidGrant(description)
        case "server_error":
            self = .ServerError(description)
        case "temporarily_unavailable":
            self = .TemporarilyUnavailable(description)
        default:
            self = .Other(error, description)
        }
    }
    
    init(_ error: Foundation.NSError) {
        self = .NSError(error)
    }
}