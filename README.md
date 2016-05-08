# SwiftyOAuth

```swift
let github: Provider = .GitHub(id: "qwerty123", secret: "secret123")

github.authorize { response in
    switch response.result {
    case .Success(let credentials):
        print(credentials.token)
    case .Failure(let error):
        print(error)
    }
}
```
