<p align="center">
  <img src="https://raw.githubusercontent.com/delba/SwiftyOAuth/assets/SwiftyOAuth%402x.png">
</p>

<p align="center">
    <a href="https://travis-ci.org/delba/SwiftyOAuth"><img alt="Travis Status" src="https://img.shields.io/travis/delba/SwiftyOAuth.svg"/></a>
    <a href="https://img.shields.io/cocoapods/v/SwityOAuth.svg"><img alt="CocoaPods compatible" src="https://img.shields.io/cocoapods/v/SwiftyOAuth.svg"/></a>
    <a href="https://github.com/Carthage/Carthage"><img alt="Carthage compatible" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/></a>
</p>

**SwiftyOAuth** is a *small* OAuth library with a built-in set of providers and a nice API to add your owns.

```swift
let instagram: Provider = .Instagram(clientID: "***", redirectURL: "foo://callback")

instagram.authorize { result in
    print(result) // Success(Token(accessToken: "abc123"))
}
```

<p align="center">
  <a href="#usage">Usage</a> • <a href="#references">References</a> • <a href="#installation">Installation</a> • <a href="#license">License</a>
</p>

## Usage

#### Provider

Initialize a provider with the custom URL scheme that you defined:

```swift
// Provider using the server-side (explicit) flow

let provider = Provider(
    clientID: "***",
    clientSecret: "***",
    authorizeURL: "https://example.com/authorize",
    tokenURL: "https://example.com/authorize/token",
    redirectURL: "foo://callback"
)

// Provider using the client-side (implicit) flow

let provider = Provider(
    clientID: "***",
    authorizeURL: "https://example.com/authorize",
    redirectURL: "foo://callback"
)
```

Alternatively, you can use one of the [built-in providers](https://github.com/delba/SwiftyOAuth#providers):

```swift
let github = .GitHub(
    clientID: "***",
    clientSecret: "***",
    redirectURL: "foo://callback"
)
```

Optionally set the `state` and `scope` properties:

```swift
github.state = "asdfjkl;" // An random string used to protect against CSRF attacks.
github.scope = "public_repo"
```

Define additional parameters for the authorization request or the token request with `additionalParamsForAuthorization` and `additionalParamsForTokenRequest` respectively:

```swift
github.additionalParamsForAuthorization["allow_signup"] = false
```

Handle the incoming requests in your `AppDelegate`:

```swift
func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    github.handleURL(url, options: options)

    return true
}
```

Finally, ask for authorization. SwiftyOAuth will either present a `SFSafariViewController` (iOS 9) or open mobile safari.

```swift
github.authorize { (result: Result<Token, Error>) -> Void in
    switch result {
    case .Success(let token):
        print(token)
    case .Failure(let error):
        print(error)
    }
}
```

#### Token

The `access_token`, `token_type` and `scope` are available as `Token` properties:

```swift
token.accessToken // abc123
token.tokenType // bearer
token.scope // public_repo
```

Additionally, you can access all the response data via the `dictionary` property:

```swift
token.dictionary // ["access_token": "abc123, "token_type": "bearer", "scope": "public_repo"]
```

#### Error

**Error** is a enum that conforms to the `ErrorType` protocol.

- `Cancel` The user cancelled the authorization process by closing the web browser window.

- `ApplicationSuspended` The OAuth application you set up has been suspended.

- `RedirectURIMismatch` The provided `redirectURL` that doesn't match what you've registered with your application.

- `AccessDenied` The user rejects access to your application.

- `IncorrectClientCredentials` The `clientID` and or `clientSecret` you passed are incorrect.

- `BadVerificationCode` The verification code you passed is incorrect, expired, or doesn't match what you received in the first request for authorization.

- `Other` The application emitted a response in the form of `{"error": "xxx", "error_description": "yyy"}` but SwiftyOAuth doesn't have a enum for it. The data is available in the associated values.

- `Unknown` The application emitted a response that is neither in the form of a success one (`{"access_token": "xxx"...}`) nor in the form of a failure one (`{"error": "xxx"...}`). The data is available in the associated value.

- `NSError` An error triggered when making network requests or parsing JSON. The data is available in the associated value.

#### Providers

- GitHub - [code](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/GitHub.swift), [doc](https://developer.github.com/v3/oauth/)
- Dribbble - [code](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Dribbble.swift), [doc](http://developer.dribbble.com/v1/oauth/)
- Instagram - [code](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Instagram.swift), [doc](https://www.instagram.com/developer/authentication/)
- *More to come...*

### Roadmap

- [x] Support for the client-side (implicit) flow
- [ ] Store the token in the Keychain
- [ ] Refresh token (when available)

## References

### Token

| Provider      | `access_token` | `token_type` | `scope`  |
| ------------- | -------------- | ------------ | -------- |
| **GitHub**    | yes            | yes          | yes      |
| **Dribbble**  | yes            | yes          | yes      |
| **Instagram** | yes            | no           | no       |

### Parameters

##### Authorize request params

| Provider      | `client_id` | `redirect_uri` | `scope`  | `state`  | Additional parameters |
| ------------- | ----------- | -------------- | -------- | -------- | --------------------- |
| **GitHub**    | required    | optional       | optional | optional | `allow_signup`        |
| **Dribbble**  | required    | optional       | optional | optional |                       |
| **Instagram** | required    | optional       | optional | optional |                       |

##### Token request params

| Provider     | `code`   | `client_id` | `client_secret` | `redirect_uri` | `state`  |
| ------------ | -------- | ----------- | --------------- | -------------- | -------- |
| **GitHub**   | required | required    | required        | optional       | optional |
| **Dribbble** | required | required    | required        | optional       |          |

### Errors

##### Authorize request errors

| Provider      | `.ApplicationSuspended` | `.RedirectURIMismatch`  | `.AccessDenied` |
| ------------- | ----------------------- | ----------------------- | --------------- |
| **GitHub**    | `application_suspended` | `redirect_uri_mismatch` | `access_denied` |
| **Dribbble**  | `application_suspended` | `redirect_uri_mismatch` | `access_denied` |
| **Instagram** |                         |                         | `access_denied` |

##### Token request errors

| Provider     | `.IncorrectClientCredentials`  | `.RedirectURIMismatch`  | `.BadVerificationCode`  |
| ------------ | ------------------------------ | ----------------------- | ----------------------- |
| **GitHub**   | `incorrect_client_credentials` | `redirect_uri_mismatch` | `bad_verification_code` |
| **Dribbble** | `invalid_client`               | `invalid_grant`         | `invalid_grant`         |

## Installation

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate **SwiftyOAuth** into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "delba/SwiftyOAuth" >= 0.2
```

#### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate **SwiftyOAuth** into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
use_frameworks!

pod 'SwiftyOAuth', '~> 0.2'
```

## License

Copyright (c) 2016 Damien (http://delba.io)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
