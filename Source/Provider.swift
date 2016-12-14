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

open class Provider: NSObject {
    public typealias Completion = (Result<Token, Error>) -> Void
    
    /// The client ID.
    open let clientID: String
    
    /// The client secret.
    open let clientSecret: String?
    
    /// The authorize URL.
    open let authorizeURL: URL?
    
    /// The token URL.
    open let tokenURL: URL?
    
    /// The redirect URL.
    open let redirectURL: URL?
    
    /// Whether the in-app browser is a WKWebView
    open var useWebView = false
    
    /// The response type.
    fileprivate let responseType: ResponseType
    
    /// The token.
    open internal(set) var token: Token? {
        get { return tokenStore.getTokenForProvider(self) }
        set { tokenStore.setToken(newValue, forProvider: self) }
    }
    
    /// The scopes.
    open var scopes: [String]?
    
    /// The scope.
    fileprivate var scope: String? {
        return scopes?.joined(separator: " ")
    }
    
    /// The state.
    open var state: String?
    
    /// The additional parameters for the authorization request.
    open var additionalAuthRequestParams: [String: String] = [:]
    
    /// The additional parameters for the token request.
    open var additionalTokenRequestParams: [String: String] = [:]
    
    /// The block to be executed when the authorization process ends.
    fileprivate var completion: Completion?
    
    /// The in-app browser.
    fileprivate var safariVC: UIViewController?
    
    /// The Token Store used to store the token.
    open var tokenStore: TokenStore = UserDefaults.standard
    
    /**
     Creates a provider that uses the client-side (implicit) flow.
     
     - parameter clientID:     The client ID.
     - parameter authorizeURL: The authorization request URL.
     - parameter redirectURL:  The redirect URL.
     
     - returns: A newly created provider.
     */
    public init(clientID: String, authorizeURL: URLStringConvertible, redirectURL: URLStringConvertible) {
        self.clientID = clientID
        self.clientSecret = nil
        self.authorizeURL = URL(string: authorizeURL.URLString)!
        self.tokenURL = nil
        self.redirectURL = URL(string: redirectURL.URLString)!
        self.responseType = .token
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
    public init(clientID: String, clientSecret: String, authorizeURL: URLStringConvertible, tokenURL: URLStringConvertible, redirectURL: URLStringConvertible) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.authorizeURL = URL(string: authorizeURL.URLString)!
        self.tokenURL = URL(string: tokenURL.URLString)!
        self.redirectURL = URL(string: redirectURL.URLString)!
        self.responseType = .code
    }

    /**
     Creates a provider that uses the client credentials or password flow.
     
     - parameter clientID:     The client ID.
     - parameter clientSecret: The client secret.
     - parameter tokenURL:     The token request URL.
     
     - returns: A newly created provider.
     */
    public init(clientID: String, clientSecret: String, tokenURL: URLStringConvertible) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.authorizeURL = nil
        self.tokenURL = URL(string: tokenURL.URLString)!
        self.redirectURL = nil
        self.responseType = .client
    }
    
    /**
     Requests access to the OAuth application.
     
     - parameter completion: The block to be executed when the authorization process ends.
     */
    open func authorize(user: String? = nil, pass: String? = nil, _ completion: @escaping Completion) {
        self.completion = completion as Completion?
        
        switch responseType {
        case .token, .code:
            visit(URL: authorizeURL!.queries(authRequestParams))
        case .client, .ownertoken:
            //  if user and pass are supplied, use resource owner password flow
            if let user = user, let pass = pass {
                requestToken(.password(user: user, pass: pass), completion: completion)
                return
            }
            //  otherwise use client-credentials flow
            requestToken(.clientCredentials, completion: completion)
        }
    }
    
    /**
     Refreshes the token.
     
     - parameter completion: The block to be executed when the refresh token process ends.
     */
    open func refreshToken(_ completion: @escaping Completion) {
        guard let refreshToken = token?.refreshToken else {
            let error = Error.other("", "")
            completion(Result.failure(error))
            return
        }
        
        requestToken(.refreshToken(refreshToken), completion: completion)
    }
    
    /**
     Handles the incoming URL.
     
     - parameter URL:     The incoming URL to handle.
     - parameter options: A dictionary of launch options.
     */
    @available(iOS 9.0, *)
    open func handleURL(_ URL: Foundation.URL, options: [UIApplicationOpenURLOptionsKey: Any]) {
        let sourceApplication = options[.sourceApplication] as? String
        
        handleURL(URL, sourceApplication: sourceApplication)
    }
    
    /**
     Handles the incoming URL.
     
     - parameter URL:               The incoming URL to handle.
     - parameter sourceApplication: The source application.
     */
    @available(*, deprecated: 9.0, message: "Use handleURL:options: in application:openURL:options: instead.")
    open func handleURL(_ URL: Foundation.URL, sourceApplication: String?) {
        guard shouldHandleURL(URL, sourceApplication: sourceApplication) else { return }
        
        handleURL(URL)
    }
    
    internal func handleURL(_ URL: Foundation.URL) {
        safariVC?.dismiss(animated: true, completion: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive)
        
        guard let completion = completion else { return }
        
        switch responseType {
        case .token, .client, .ownertoken: handleURLForTokenResponseType(URL, completion: completion)
        case .code: handleURLForCodeResponseType(URL, completion: completion)
        }
    }
}

// MARK: - Requests Params

private extension Provider {
    var authRequestParams: [String: String] {
        var params = [
            "client_id": clientID,
            "redirect_uri": redirectURL!.absoluteString
        ]
        
        if let scope = scope { params["scope"] = scope }
        if let state = state { params["state"] = state }
        
        params.merge(responseType.params)
        params.merge(additionalAuthRequestParams)
        
        return params
    }
    
    func tokenRequestParams(_ grantType: GrantType) -> [String: String] {
        var params = [
            "client_id": clientID,
            "client_secret": clientSecret!
        ]
        
        if let redirectURL = redirectURL { params["redirect_uri"] = redirectURL.absoluteString }
        if let scope = scope { params["scope"] = scope }
        if let state = state { params["state"] = state }
        
        params.merge(grantType.params)
        params.merge(additionalTokenRequestParams)
        
        return params
    }
}

// MARK: - Visit URL

private extension Provider {
    func visit(URL: Foundation.URL) {
        if useWebView {
            safariVC = WebViewController(URL: URL, delegate: self)
            UIApplication.shared.presentViewController(safariVC!)
            return
        }
        
        if #available(iOS 9.0, *) {
            safariVC = SFSafariViewController(URL: URL, delegate: self)
            UIApplication.shared.presentViewController(safariVC!)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(Provider.didBecomeActive(_:)), name: .UIApplicationDidBecomeActive)
            UIApplication.shared.openURL(URL)
        }
    }
}

// MARK: - Handle Incoming URL

private extension Provider {
    func handleURLForTokenResponseType(_ URL: Foundation.URL, completion: @escaping (Result<Token, Error>) -> Void) {
        let result: Result<Token, Error>
        
        if let token = Token(dictionary: URL.fragments) {
            self.token = token
            result = .success(token)
        } else {
            result = .failure(Error(URL.fragments))
        }
        
        Queue.main { completion(result) }
    }
    
    func handleURLForCodeResponseType(_ URL: Foundation.URL, completion: @escaping (Result<Token, Error>) -> Void) {
        guard let code = URL.queries["code"] else {
            let error = Error(URL.queries)
            
            Queue.main { completion(.failure(error)) }
            
            return
        }
        
        requestToken(.authorizationCode(code), completion: completion)
    }
    
    func shouldHandleURL(_ URL: Foundation.URL, sourceApplication: String?) -> Bool {
        guard isLegitSourceApplication(sourceApplication) else { return false }
        
        return shouldHandleURL(URL)
    }
    
    func isLegitSourceApplication(_ sourceApplication: String?) -> Bool {
        guard let sourceApplication = sourceApplication else { return false }
        
        return ["com.apple.mobilesafari", "com.apple.SafariViewService"].contains(sourceApplication)
    }
    
    func matchingURLs(_ a: URL, _ b: URL) -> Bool {
        return (a.scheme, a.host, a.path) == (b.scheme, b.host, b.path)
    }
}

internal extension Provider {
    func shouldHandleURL(_ URL: Foundation.URL) -> Bool {
        guard state == URL.queries["state"] else { return false }
        
        return matchingURLs(URL, redirectURL!)
    }
}

// MARK: - Request Token

private extension Provider {
    func requestToken(_ grantType: GrantType, completion: @escaping Completion) {
        let params = tokenRequestParams(grantType)
        
        HTTP.POST(tokenURL!, parameters: params) { resultJSON in
            let result: Result<Token, Error>
            
            switch resultJSON {
            case .success(let json):
                if let token = Token(dictionary: json) {
                    self.token = token
                    result = .success(token)
                } else {
                    result = .failure(Error(json))
                }
            case .failure(let error):
                result = .failure(Error(error as NSError))
            }
            
            Queue.main { completion(result) }
        }
    }
}

// MARK: - Close Browser Window

@available(iOS 9.0, *)
extension Provider: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        safariVC?.dismiss(animated: true, completion: nil)
        
        if let completion = completion {
            Queue.main { completion(.failure(.cancel)) }
        }
    }
}

extension Provider: WebViewControllerDelegate {
    func webViewControllerDidFinish(_ controller: WebViewController) {
        safariVC?.dismiss(animated: true, completion: nil)
        
        if let completion = completion {
            Queue.main { completion(.failure(.cancel)) }
        }
    }
}

extension Provider {
    @objc func didBecomeActive(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive)
        
        if let completion = completion {
            Queue.main { completion(.failure(.cancel)) }
        }
    }
}
