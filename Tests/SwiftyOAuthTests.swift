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
    
    func testAuthenticateRequestSuccess(){
        let provider = Provider(clientID: "testing_client_id", authorizeURL: "testing_authorize_url", redirectURL: "redirect_url")
        let store = NSUserDefaults.standardUserDefaults()
        provider.tokenStore = store
        
        store.setToken(token, forProvider: provider)
        
        let originalRequest = NSURLRequest(URL: NSURL(string: "http://siwfityoauth.delba.io")!)
        let expectation = expectationWithDescription("Authenticate a NSURLRequest")
        
        provider.authenticateRequest(originalRequest) { [unowned self] (result) in
            switch result {
            case .Success(let authenticatedRequest):
                XCTAssertEqual(originalRequest.HTTPMethod, originalRequest.HTTPMethod)
                XCTAssertEqual(originalRequest.HTTPBody, originalRequest.HTTPBody)
                XCTAssertEqual(originalRequest.cachePolicy, originalRequest.cachePolicy)
                XCTAssertEqual(originalRequest.HTTPShouldHandleCookies, originalRequest.HTTPShouldHandleCookies)
                XCTAssertEqual(originalRequest.HTTPBodyStream, originalRequest.HTTPBodyStream)
                XCTAssertEqual(originalRequest.URL, originalRequest.URL)
                
                XCTAssertEqual(authenticatedRequest.valueForHTTPHeaderField("Authorization"), "Bearer \(self.token!.accessToken)")
            case .Failure(let error):
                XCTFail(error.description);
            }
            
            // Clean up
            store.setToken(nil, forProvider: provider)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testAuthenticateRequestFailureBecauseNoTokenAvailable(){
        let provider = Provider(clientID: "testing_client_id", clientSecret: "testing_client_secret", authorizeURL: "http://authorize.success.siwfityoauth.delba.io", tokenURL: "http://tokenurl.siwfityoauth.delba.io", redirectURL: "swiftyoauth://redirectURL.siwfityoauth.delba.io")
        let store = NSUserDefaults.standardUserDefaults()
        provider.tokenStore = store
        
        let originalRequest = NSURLRequest(URL: NSURL(string: "http://siwfityoauth.delba.io")!)
        let expectation = expectationWithDescription("Fail to Authenticate a NSURLRequest because of missing token.")
        
        provider.authenticateRequest(originalRequest) { (result) in
            switch result {
            case .Success( _):
                XCTFail("Shouldn't be possible to retrieve an authenticated request since no access token should be available")
            case .Failure(let error):
                XCTAssertEqual(error.code, SwiftyOAuthErrorCode.InvalidAccessToken.rawValue, "Received wrong error code")
            }
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testAuthenticateRequestFailureRenewExpiredToken() {
        let provider = Provider(clientID: "testing_client_id", clientSecret: "testing_client_secret", authorizeURL: "http://authorize.success.siwfityoauth.delba.io", tokenURL: "http://tokenurl.siwfityoauth.delba.io", redirectURL: "swiftyoauth://redirectURL.siwfityoauth.delba.io")
        let store = NSUserDefaults.standardUserDefaults()
        provider.tokenStore = store
        
        store.setToken(expiredToken, forProvider: provider)
        
        let originalRequest = NSURLRequest(URL: NSURL(string: "http://siwfityoauth.delba.io")!)
        let expectation = expectationWithDescription("Authenticate a NSURLRequest by refreshing an expired token.")
        
        
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return (request.URL!.absoluteString == "http://tokenurl.siwfityoauth.delba.io")
            }, withStubResponse: { [unowned self] request in
                print(self.bundle.pathForResource("authorize-valid", ofType: "json")!)
                return OHHTTPStubsResponse(data: NSData(contentsOfFile: self.bundle.pathForResource("authorize-valid", ofType: "json")!)!, statusCode: 200, headers: [ "Content-Type": "application/json" ])
        })
        
        provider.authenticateRequest(originalRequest) { [unowned self] (result) in
            switch result {
            case .Success(let authenticatedRequest):
                XCTAssertEqual(originalRequest.HTTPMethod, originalRequest.HTTPMethod)
                XCTAssertEqual(originalRequest.HTTPBody, originalRequest.HTTPBody)
                XCTAssertEqual(originalRequest.cachePolicy, originalRequest.cachePolicy)
                XCTAssertEqual(originalRequest.HTTPShouldHandleCookies, originalRequest.HTTPShouldHandleCookies)
                XCTAssertEqual(originalRequest.HTTPBodyStream, originalRequest.HTTPBodyStream)
                XCTAssertEqual(originalRequest.URL, originalRequest.URL)
                XCTAssertEqual(authenticatedRequest.valueForHTTPHeaderField("Authorization"), "Bearer \(self.expiredToken!.accessToken)")
                
                // Clean up
                store.setToken(nil, forProvider: provider)
            case .Failure(let error):
                XCTFail(error.description);
            }
            
            // Clean up
            store.setToken(nil, forProvider: provider)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
