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
let instagram: Provider = .instagram(clientID: "***", redirectURL: "foo://callback")

instagram.authorize { result in
    print(result) // success(Token(accessToken: "abc123"))
}
```

<p align="center">
  <a href="#usage">Usage</a> • <a href="#providers">Providers</a> • <a href="#installation">Installation</a> • <a href="#license">License</a>
</p>

## Usage

#### Provider

[`Provider.swift`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Provider.swift)

##### Step 1: Create a provider 

Initialize a provider with the custom URL scheme that you defined:

```swift
// Provider using the server-side (explicit) flow

let provider = Provider(
    clientID:     "***",
    clientSecret: "***",
    authorizeURL: "https://example.com/authorize",
    tokenURL:     "https://example.com/authorize/token",
    redirectURL:  "foo://callback"
)

// Provider using the client-side (implicit) flow

let provider = Provider(
    clientID:     "***",
    authorizeURL: "https://example.com/authorize",
    redirectURL:  "foo://callback"
)

// Provider using the client-credentials flow

let provider = Provider(
    clientID:     "***",
    clientSecret: "***"
)
```

Alternatively, you can use one of the [built-in providers](https://github.com/delba/SwiftyOAuth#providers):

```swift
let github = .gitHub(
    clientID:     "***",
    clientSecret: "***",
    redirectURL:  "foo://callback"
)
```

Optionally set the `state` and `scopes` properties:

```swift
github.state  = "asdfjkl;" // An random string used to protect against CSRF attacks.
github.scopes = ["user", "repo"]
```

Use a `WKWebView` if the provider doesn't support custom URL schemes as redirect URLs.

```swift
let provider = Provider(
    clientID:     "***",
    clientSecret: "***",
    authorizeURL: "https://example.com/authorize",
    tokenURL:     "https://example.com/authorize/token",
    redirectURL:  "https://an-arbitrary-redirect-url/redirect"
)

provider.useWebView = true
```

Define additional parameters for the authorization request or the token request with `additionalAuthRequestParams` and `additionalTokenRequestParams` respectively:

```swift
github.additionalAuthRequestParams["allow_signup"] = "false"
```

##### Step 2: Handle the incoming requests

Handle the incoming requests in your `AppDelegate`:

```swift
func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    github.handleURL(url, options: options)

    return true
}
```

##### Step 3: Ask for authorization

Finally, ask for authorization. SwiftyOAuth will either present a `SFSafariViewController` (iOS 9) or open mobile safari.

```swift
github.authorize { (result: Result<Token, Error>) -> Void in
    switch result {
    case .success(let token): print(token)
    case .failure(let error): print(error)
    }
}
```

If the provider provides an expirable token, you may want to refresh it.

```swift
let uber: Provider = .Uber(
    clientID: "***",
    clientSecret: "***",
    redirectURL: "foo://callback/uber"
)

// uber.token!.isExpired => true

uber.refreshToken { result in
    switch result {
    case .success(let token): print(token)
    case .failure(let error): print(error)
    }
}
```

#### Token

[`Token.swift`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Token.swift)

The `access_token`, `token_type`, `scopes`, and informations related to the expiration are available as `Token` properties:

```swift
token.accessToken // abc123
token.tokenType   // .Bearer
token.scopes      // ["user", "repo"]

token.expiresIn // 123
token.isExpired // false
token.isValid   // true
```

Additionally, you can access all the token data via the `dictionary` property:

```swift
token.dictionary // ["access_token": "abc123", "token_type": "bearer", "scope": "user repo"]
```

#### Token Store

Every `Token` is stored and retrieved through an object that conforms to the `TokenStore` protocol.

The library currently supports following `TokenStore`s:

```swift
provider.tokenStore = Keychain.shared
```

**`Keychain`**: Before you use this`TokenStore`, make sure you turn on the *Keychain Sharing* capability.

```swift
provider.tokenStore = UserDefault.standard
```

**`UserDefaults`**: the default `TokenStore`. Information are saved locally and, if properly initialized, to your *App Group*.

```swift
provider.tokenStore = NSUbiquitousKeyValueStore.default()
```

**`NSUbiquitousKeyValueStore`**: the information are saved in the *iCloud Key Value Store*. Before you use this `TokenStore` make sure your project has been properly configured as described [here](https://developer.apple.com/library/mac/documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html#//apple_ref/doc/uid/TP40012094-CH6-SW26).

#### Error

[`Error.swift`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Error.swift)

**Error** is a enum that conforms to the `ErrorType` protocol.

- `cancel` The user cancelled the authorization process by closing the web browser window.

- `applicationSuspended` The OAuth application you set up has been suspended.

- `redirectURIMismatch` The provided `redirectURL` that doesn't match what you've registered with your application.

- `accessDenied` The user rejects access to your application.

- `invalidClient` The `clientID` and or `clientSecret` you passed are incorrect.

- `invalidGrant` The verification code you passed is incorrect, expired, or doesn't match what you received in the first request for authorization.

- `other` The application emitted a response in the form of `{"error": "xxx", "error_description": "yyy"}` but SwiftyOAuth doesn't have a enum for it. The data is available in the associated values.

- `unknown` The application emitted a response that is neither in the form of a success one (`{"access_token": "xxx"...}`) nor in the form of a failure one (`{"error": "xxx"...}`). The data is available in the associated value.

- `nsError` An error triggered when making network requests or parsing JSON. The data is available in the associated value.

#### Providers

[`Providers/`](https://github.com/delba/SwiftyOAuth/tree/master/Source/Providers)

- [`GitHub`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/GitHub.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/GitHub)
- [`Dribbble`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Dribbble.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Dribbble)
- [`Instagram`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Instagram.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Instagram)
- [`Uber`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Uber.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Uber)
- [`Feedly`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Feedly.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Feedly)
- [`Vimeo`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Vimeo.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Vimeo)
- [`SoundCloud`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/SoundCloud.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/SoundCloud)
- [`StackExchange`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/StackExchange.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/StackExchange)
- [`Medium`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Medium.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Medium)
- [`Foursquare`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Foursquare.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Foursquare)
- [`Stripe`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Stripe.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Stripe)
- [`Reddit`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Reddit.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Reddit)
- [`Weibo`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Weibo.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Weibo)
- [`Slack`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Slack.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Slack)
- [`Dropbox`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Dropbox.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Dropbox)
- [`Basecamp`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Basecamp.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Basecamp)
- [`Spotify`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Spotify.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Spotify)
- [`Meetup`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Meetup.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Meetup)
- [`Strava`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Strava.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Strava)
- [`Google`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Google.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Google)
- [`Stuart`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/Stuart.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/Stuart)
- [`UberRUSH`](https://github.com/delba/SwiftyOAuth/blob/master/Source/Providers/UberRUSH.swift) - [**doc**](https://github.com/delba/SwiftyOAuth/wiki/UberRUSH)
- *More to come...*

Check the [**wiki**](https://github.com/delba/SwiftyOAuth/wiki) for more informations!

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
github "delba/SwiftyOAuth" >= 1.1
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

pod 'SwiftyOAuth', '~> 1.1'
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
