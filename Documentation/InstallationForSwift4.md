## Installation for Swift 4
#### CocoaPods
**:warning: CocoaPods (`1.1.0 or later`) is required.**

Adding it to your `Podfile`:
```ruby
use_frameworks!
pod 'Kanna', '~> 4.0.0'
```

#### Carthage
Adding it to your `Cartfile`:

```ogdl
github "tid-kijyun/Kanna" ~> 4.0.0
```

1. In the project settings add `$(SDKROOT)/usr/include/libxml2` to the "header search paths" field

#### Swift Package Manager

Installing libxml2 to your computer:

```bash
// macOS
$ brew install libxml2
$ brew link --force libxml2

// Linux(Ubuntu)
$ sudo apt-get install libxml2-dev
```

Adding it to your `Package.swift`:

```swift
// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "YourProject",
    dependencies: [
        .package(url: "https://github.com/tid-kijyun/Kanna.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "YourTarget",
            dependencies: ["Kanna"]),
    ]
)
```

```bash
$ swift build
```

*Note: When a build error occurs, please try run the following command:*
```bash
$ sudo apt-get install pkg-config
```

