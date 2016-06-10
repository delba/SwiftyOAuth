//
// Provider.swift
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

public class Provider: NSObject {
    /// The client ID.
    public let clientID: String
    /// The client secret.
    public let clientSecret: String?
    
    /// The authorize URL.
    public let authorizeURL: NSURL
    /// The token URL.
    public let tokenURL: NSURL?
    /// The redirect URL.
    public let redirectURL: NSURL
    
    /// The response type.
    private let responseType: ResponseType
    
    /// The token.
    public internal(set) var token: Token? {
        get { return tokenStore.getTokenForProvider(self) }
        set { tokenStore.setToken(newValue, forProvider: self) }
    }
    
    /// The scopes.
    public var scopes: [String]?
    
    /// The scope.
    private var scope: String? {
        return scopes?.joinWithSeparator(" ")
    }
    
    /// The state.
    public var state: String?
    
    /// The additional parameters for the authorization request.
    public var additionalAuthRequestParams: [String: String] = [:]
    /// The additional parameters for the token request.
    public var additionalTokenRequestParams: [String: String] = [:]
    
    /// The block to be executed when the authorization process ends.
    private var completion: (Result<Token, Error> -> Void)?
    
    private var safariVC: UIViewController?
    
    /// The Token Store used to store the token.
    public var tokenStore: TokenStore = NSUserDefaults.standardUserDefaults()
    
    /**
     Creates a provider that uses the client-side (implicit) flow.
     
     - parameter clientID:     The client ID.
     - parameter authorizeURL: The authorization request URL.
     - parameter redirectURL:  The redirect URL.
     
     - returns: A newly created provider.
     */
    public init(clientID: String, authorizeURL: String, redirectURL: String) {
        self.clientID = clientID
        self.clientSecret = nil
        self.authorizeURL = NSURL(string: authorizeURL)!
        self.tokenURL = nil
        self.redirectURL = NSURL(string: redirectURL)!
        self.responseType = .Token
    }
    
    /**
     Creates a provider that uses the server-side (explicit) flow.
     
     - parameter clientID:     The client ID.
     - parameter clientSecret: The client secret.
     - parameter authorizeURL: The authorization request URL.
     - parameter tokenURL:     The token request URL.
     - parameter redirectURL:  The redirect URL.
     
     - returns: A newly created provider.
     */
    public init(clientID: String, clientSecret: String, authorizeURL: String, tokenURL: String, redirectURL: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.authorizeURL = NSURL(string: authorizeURL)!
        self.tokenURL = NSURL(string: tokenURL)
        self.redirectURL = NSURL(string: redirectURL)!
        self.responseType = .Code
    }
    
    /**
     Requests access to the OAuth application.
     
     - parameter completion: The block to be executed when the authorization process ends.
     */
    public func authorize(completion: Result<Token, Error> -> Void) {
        self.completion = completion
        
        visit(URL: authorizeURL.queries(authRequestParams))
    }
    
    /**
     Refreshes the token.
     
     - parameter completion: The block to be executed when the refresh token process ends.
     */
    public func refreshToken(completion: Result<Token, Error> -> Void) {
        guard let refreshToken = token?.refreshToken else {
            let error = Error.Other("", "")
            completion(Result.Failure(error))
            return
        }
        
        requestToken(.RefreshToken(refreshToken), completion: completion)
    }
    
    /**
     Handles the incoming URL.
     
     - parameter URL:     The incoming URL to handle.
     - parameter options: A dictionary of launch options.
     */
    public func handleURL(URL: NSURL, options: [String: AnyObject]) {
        guard shouldHandleURL(URL, options: options) else { return }
        
        safariVC?.dismissViewControllerAnimated(true, completion: nil)
        NotificationCenter.removeObserver(self, name: UIApplicationDidBecomeActiveNotification)
        
        guard let completion = completion else { return }
        
        switch responseType {
        case .Token: handleURLForTokenResponseType(URL, completion: completion)
        case .Code: handleURLForCodeResponseType(URL, completion: completion)
        }
    }
    
    /// Alters the given request by adding authentication, if possible.
    ///
    /// In case of an expired access token and the presence of a refresh token,
    /// automatically tries to refresh the access token. If refreshing the
    /// access token fails, the access token is cleared.
    ///
    /// **Note:** If the access token must be refreshed, network I/O is
    ///     performed.
    ///
    /// **Note:** The completion closure may be invoked on any thread.
    ///
    /// - parameter request: An unauthenticated NSURLRequest.
    /// - parameter completion: A callback to invoke with the authenticated request.
    public func authenticateRequest(request: NSURLRequest, completion: Result<NSURLRequest, NSError> -> ()) {
        if let token = token {
            if token.isValid {
                let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
                mutableRequest.setAccessToken(token)
                completion(Result.Success(mutableRequest))
            } else {
                // Invalid token.
                if token.isExpired {
                    // It is expired. Let's refresh it.
                    refreshToken({ [weak self] (result) in
                        switch result {
                        case .Success( _):
                            self?.authenticateRequest(request, completion: completion)
                        case .Failure(let error):
                            completion(Result.Failure(error.nsError))
                        }
                    })
                } else {
                    // Not handled. Complete with error.
                    let error = Error.InvalidAccessToken("Access token is invalid. Please rissue a new access token")
                    completion(Result.Failure(error.nsError))
                }
            }
        } else {
            // No token available. The client must start an authentication process properly through -authorize method
            let error = Error.InvalidAccessToken("No access token found. Please reissue a new access token through -authorize method")
            completion(Result.Failure(error.nsError))
        }
    }
}

// MARK: - Requests Params

private extension Provider {
    var authRequestParams: [String: String] {
        var params = [
            "client_id": clientID,
            "redirect_uri": redirectURL.absoluteString
        ]
        
        if let scope = scope { params["scope"] = scope }
        if let state = state { params["state"] = state }
        
        params.merge(responseType.params)
        params.merge(additionalAuthRequestParams)
        
        return params
    }
    
    func tokenRequestParams(grantType: GrantType) -> [String: String]? {
        
        guard let clientSecret = clientSecret else {
            return nil
        }
        
        var params = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURL.absoluteString
        ]
        
        if let state = state { params["state"] = state }
        
        params.merge(grantType.params)
        params.merge(additionalTokenRequestParams)
        
        return params
    }
}

// MARK: - Visit URL

private extension Provider {
    func visit(URL URL: NSURL) {
        if #available(iOS 9.0, *) {
            safariVC = SFSafariViewController(URL: URL, delegate: self)
            Application.presentViewController(safariVC!)
        } else {
            NotificationCenter.addObserver(self, selector: #selector(Provider.didBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification)
            Application.openURL(URL)
        }
    }
}

// MARK: - Handle Incoming URL

private extension Provider {
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
    
    func handleURLForCodeResponseType(URL: NSURL, completion: Result<Token, Error> -> Void) {
        guard let code = URL.queries["code"] else {
            let error = Error(URL.queries)
            
            Queue.main { completion(.Failure(error)) }
            
            return
        }
        
        requestToken(.AuthorizationCode(code), completion: completion)
    }
    
    func shouldHandleURL(URL: NSURL, options: [String: AnyObject]) -> Bool {
        guard isLegitSourceApplication(options) else {
            return false
        }
        
        guard state == URL.queries["state"] else {
            return false
        }
        
        return matchingURLs(URL, redirectURL) ? true : false
    }
    
    func isLegitSourceApplication(options: [String: AnyObject]) -> Bool {
        guard let sourceApplication = options["UIApplicationOpenURLOptionsSourceApplicationKey"] as? String else {
            return false
        }
        
        return ["com.apple.mobilesafari", "com.apple.SafariViewService"].contains(sourceApplication)
    }
    
    func matchingURLs(a: NSURL, _ b: NSURL) -> Bool {
        return (a.scheme, a.host, a.path) == (b.scheme, b.host, b.path)
    }
}

// MARK: - Request Token

private extension Provider {
    func requestToken(grantType: GrantType, completion: Result<Token, Error> -> Void) {
        guard let params = tokenRequestParams(grantType) else {
            Queue.main {completion(.Failure(Error.InvalidRequest("Wrong token information provided"))) }
            return
        }
        
        if let tokenURL = tokenURL {
            HTTP.POST(tokenURL, parameters: params) { [unowned self] resultJSON in
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
        } else {
            Queue.main {completion(.Failure(Error.InvalidRequest("Wrong token URL provided: \(self.tokenURL)"))) }
        }
    }
}

// MARK: - Close Browser Window

@available(iOS 9.0, *)
extension Provider: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(controller: SFSafariViewController) {
        safariVC?.dismissViewControllerAnimated(true, completion: nil)
        
        if let completion = completion {
            Queue.main { completion(.Failure(.Cancel)) }
        }
    }
}

extension Provider {
    @objc func didBecomeActive(notification: NSNotification) {
        NotificationCenter.removeObserver(self, name: UIApplicationDidBecomeActiveNotification)
        
        if let completion = completion {
            Queue.main { completion(.Failure(.Cancel)) }
        }
    }
}