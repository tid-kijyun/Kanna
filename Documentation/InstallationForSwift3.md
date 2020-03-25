## Installation for Swift 3
For now, please use the `feature/v3.0.0` branch.

#### CocoaPods
**:warning: CocoaPods (`1.1.0 or later`) is required.**

Adding it to your `Podfile`:
```ruby
use_frameworks!
pod 'Kanna', :git => 'https://github.com/tid-kijyun/Kanna', :branch => 'feature/v3.0.0'
```

#### Carthage
Adding it to your `Cartfile`:

```ogdl
github "tid-kijyun/Kanna" "feature/v3.0.0"
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
import PackageDescription

let package = Package(
    name: "YourProject",
    
    dependencies: [
        .Package(url: "https://github.com/tid-kijyun/Kanna.git", majorVersion: 2)
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

#### Manual Installation
1. Add these files to your project:  
  [Kanna.swift](Source/Kanna.swift)  
  [CSS.swift](Source/CSS.swift)  
  [libxmlHTMLDocument.swift](Source/libxml/libxmlHTMLDocument.swift)  
  [libxmlHTMLNode.swift](Source/libxml/libxmlHTMLNode.swift)  
  [libxmlParserOption.swift](Source/libxml/libxmlParserOption.swift)  
  [Modules](Modules)
1. In the target settings add `$(SDKROOT)/usr/include/libxml2` to the `Search Paths > Header Search Paths` field
1. In the target settings add `$(SRCROOT)/Modules` to the `Swift Compiler - Search Paths > Import Paths` field

