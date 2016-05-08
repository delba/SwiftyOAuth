# SwiftyOAuth

```swift
let github: Provider = .GitHub(clientID: "xxx", clientSecret: "yyy", redirectURL: "myapp://callback")

github.authorize { result in
    if let credentials = result.credentials {
        print(credentials.token)
    }
}
```

## Usage

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
