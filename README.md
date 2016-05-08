# SwiftyOAuth

```swift
let github: Provider = .GitHub(
    clientID: "**********",
    clientSecret: "**********",
    redirectURL: "myapp://callback"
)

github.authorize { result in
    switch result {
    case .Success(let credential):
        print(credential.token)
    case .Failure(let error):
        print(error)
    }
}
```

## Usage

#### Provider

**Required**
- clientID:
- clientSecret:
- authrorizeURL:
- tokenURL: 
- redirectURL

**Optional**
- scope: String
- state: String

```swift
let provider = Provider(
    clientID: "*********",
    clientSecret: "**********",
    authorizeURL: "**********",
    tokenURL: "**********",
    redirectURL: "**********"
)

provider.state = "****"
provider.scope = "***"

provider.authorize { result in
    case Success(let credential):
        print(credential.token)
    case Failure(let error);
        print(error)
}

provider.authorize { result in
    if let credential = result.credential {
        print(credential.token)
    }
}

provider.refreshToken { result in
    if let credential = result.credential {
        print(credential.token)
    }
}
```

### Credential

```swift
credential.token
credential..

isExpired
isValid
```


### Providers

- GitHub
- Twitter
- Facebook
- Weibo
- Instagram
- Dribbble

## Demo

## Installation

#### Carthage

#### CocoaPods

## License
