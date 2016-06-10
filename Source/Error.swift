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

public let SwiftyOAuthErrorDomain = "SwiOAuthErrorDomain"

public enum SwiftyOAuthErrorCode: Int {
    case Cancel = 0
    case ApplicationSuspended = 1
    case RedirectURIMismatch = 2
    case AccessDenied = 3
    case InvalidRequest = 4
    case InvalidScope = 5
    case InvalidClient = 6
    case InvalidGrant = 7
    case ServerError = 8
    case TemporarilyUnavailable = 9
    case Other = 10
    case Unknown = 11
    case NSError = 12
    case InvalidAccessToken = 13
    case JSONDeserialization = 14
    case HTTPNoDataReturned = 15
}

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
    
    /// The application has an invalid access token. This error is returned when the invalid state of the token requires a new authorization process. Expired access token are already properly handled in order to be refreshed
    case InvalidAccessToken(String)
    
    /// An error occured while deserializing a JSON response.
    case JSONDeserializationError(String)
    
    /// An error occured while parsing an HTTP response which returned nothing.
    case HTTPNoDataReturned(String)
    
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

extension Error {
    private func description() -> String {
        switch self {
        case Cancel:
            return "Operation cancelled"
        case ApplicationSuspended(let description):
            return description
        case RedirectURIMismatch(let description):
            return description
        case AccessDenied(let description):
            return description
        case InvalidRequest(let description):
            return description
        case InvalidScope(let description):
            return description
        case InvalidClient(let description):
            return description
        case InvalidGrant(let description):
            return description
        case ServerError(let description):
            return description
        case TemporarilyUnavailable(let description):
            return description
        case Other(let error, let description):
            return "\(error) : \(description)"
        case InvalidAccessToken(let description):
            return description
        case Unknown(let dictionary):
            return dictionary.description
        case JSONDeserializationError(let description):
            return description
        case .HTTPNoDataReturned(let description):
            return description
        default:
            return NSLocalizedString("Not available error description", comment: "The message for errors with no description")
        }
    }
    
    private func code() -> SwiftyOAuthErrorCode {
        switch self {
        case Cancel:
            return SwiftyOAuthErrorCode.Cancel
        case ApplicationSuspended( _):
            return SwiftyOAuthErrorCode.ApplicationSuspended
        case RedirectURIMismatch( _):
            return SwiftyOAuthErrorCode.RedirectURIMismatch
        case AccessDenied( _):
            return SwiftyOAuthErrorCode.AccessDenied
        case InvalidRequest( _):
            return SwiftyOAuthErrorCode.InvalidRequest
        case InvalidScope( _):
            return SwiftyOAuthErrorCode.InvalidScope
        case InvalidClient( _):
            return SwiftyOAuthErrorCode.InvalidClient
        case InvalidGrant( _):
            return SwiftyOAuthErrorCode.InvalidGrant
        case ServerError( _):
            return SwiftyOAuthErrorCode.ServerError
        case TemporarilyUnavailable( _):
            return SwiftyOAuthErrorCode.TemporarilyUnavailable
        case .InvalidAccessToken( _):
            return SwiftyOAuthErrorCode.InvalidAccessToken
        case Other( _):
            return SwiftyOAuthErrorCode.Other
        case Unknown( _):
            return SwiftyOAuthErrorCode.Unknown
        case JSONDeserializationError( _):
            return SwiftyOAuthErrorCode.JSONDeserialization
        case .HTTPNoDataReturned( _):
            return SwiftyOAuthErrorCode.HTTPNoDataReturned
        default:
            return SwiftyOAuthErrorCode.Unknown
        }
    }

    private func domain() -> String {
        return SwiftyOAuthErrorDomain
    }
    
    public var nsError: Foundation.NSError {
        switch self {
        case NSError(let error):
            return error
        default:
            var userInfo = [String: AnyObject]()
            
            userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(description(), comment: "")
            
            return Foundation.NSError(domain: SwiftyOAuthErrorDomain, code: code().rawValue, userInfo: userInfo)
        }

    }
}