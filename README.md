Kanna(鉋)
=================

Kanna(鉋) is an XML/HTML parser for cross-platform(macOS, iOS, tvOS, watchOS and Linux!).

It was inspired by [Nokogiri](https://github.com/sparklemotion/nokogiri)(鋸).

[![Build Status](https://travis-ci.org/tid-kijyun/Kanna.svg?branch=master)](https://travis-ci.org/tid-kijyun/Kanna)
[![Platform](http://img.shields.io/badge/platform-ios_osx_watchos_tvos_linux-lightgrey.svg?style=flat)](https://developer.apple.com/resources/)
[![Cocoapod](http://img.shields.io/cocoapods/v/Kanna.svg?style=flat)](http://cocoadocs.org/docsets/Kanna/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Reference Status](https://www.versioneye.com/objective-c/kanna/reference_badge.svg?style=flat)](https://www.versioneye.com/objective-c/kanna/references)

:information_source: [Documentation](http://tid-kijyun.github.io/Kanna/)


Features:
=================
- [x] XPath 1.0 support for document searching
- [x] CSS3 selector support for document searching
- [x] Support for namespaces
- [x] Comprehensive test suite

Installation:
=================

### Swift 5
##### CocoaPods
Adding it to your `Podfile`:
```ruby
use_frameworks!
pod 'Kanna', '~> 5.0.0'
```

##### Carthage
Adding it to your `Cartfile`:

```ogdl
github "tid-kijyun/Kanna" ~> 5.0.0
```

1. In the project settings add `$(SDKROOT)/usr/include/libxml2` to the "header search paths" field

##### Swift Package Manager
Adding it to your `Package.swift`:

```swift
import PackageDescription

let package = Package(
    name: "YourProject",
    
    dependencies: [
        .Package(url: "https://github.com/tid-kijyun/Kanna.git", from: "5.0.0")
    ]

    // Link xml2 (needed for Xcode builds)
    swiftSettings:[.unsafeFlags(["-I$SDKROOT/usr/include/libxml2"])],
    linkerSettings: [.linkedLibrary("xml2")]),
)
```

### Swift 4
##### CocoaPods
**:warning: CocoaPods (`1.1.0 or later`) is required.**

Adding it to your `Podfile`:
```ruby
use_frameworks!
pod 'Kanna', '~> 4.0.0'
```

##### Carthage
Adding it to your `Cartfile`:

```ogdl
github "tid-kijyun/Kanna" ~> 4.0.0
```

1. In the project settings add `$(SDKROOT)/usr/include/libxml2` to the "header search paths" field

##### Swift Package Manager

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

##### Manual Installation
1. Add these files to your project:  
  [Kanna.swift](Source/Kanna.swift)  
  [CSS.swift](Source/CSS.swift)  
  [libxmlHTMLDocument.swift](Source/libxml/libxmlHTMLDocument.swift)  
  [libxmlHTMLNode.swift](Source/libxml/libxmlHTMLNode.swift)  
  [libxmlParserOption.swift](Source/libxml/libxmlParserOption.swift)  
  [Modules](Modules)
1. In the target settings add `$(SDKROOT)/usr/include/libxml2` to the `Search Paths > Header Search Paths` field
1. In the target settings add `$(SRCROOT)/Modules` to the `Swift Compiler - Search Paths > Import Paths` field


### Swift 3.0
For now, please use the `feature/v3.0.0` branch.

##### CocoaPods
**:warning: CocoaPods (`1.1.0 or later`) is required.**

Adding it to your `Podfile`:
```ruby
use_frameworks!
pod 'Kanna', :git => 'https://github.com/tid-kijyun/Kanna', :branch => 'feature/v3.0.0'
```

##### Carthage
Adding it to your `Cartfile`:

```ogdl
github "tid-kijyun/Kanna" "feature/v3.0.0"
```

1. In the project settings add `$(SDKROOT)/usr/include/libxml2` to the "header search paths" field

##### Swift Package Manager

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

##### Manual Installation
1. Add these files to your project:  
  [Kanna.swift](Source/Kanna.swift)  
  [CSS.swift](Source/CSS.swift)  
  [libxmlHTMLDocument.swift](Source/libxml/libxmlHTMLDocument.swift)  
  [libxmlHTMLNode.swift](Source/libxml/libxmlHTMLNode.swift)  
  [libxmlParserOption.swift](Source/libxml/libxmlParserOption.swift)  
  [Modules](Modules)
1. In the target settings add `$(SDKROOT)/usr/include/libxml2` to the `Search Paths > Header Search Paths` field
1. In the target settings add `$(SRCROOT)/Modules` to the `Swift Compiler - Search Paths > Import Paths` field

Synopsis:
=================

```swift
import Kanna

let html = "<html>...</html>"

if let doc = try? HTML(html: html, encoding: .utf8) {
    print(doc.title)
    
    // Search for nodes by CSS
    for link in doc.css("a, link") {
        print(link.text)
        print(link["href"])
    }
    
    // Search for nodes by XPath
    for link in doc.xpath("//a | //link") {
        print(link.text)
        print(link["href"])
    }
}
```

```swift
let xml = "..."
if let doc = try? Kanna.XML(xml: xml, encoding: .utf8) {
    let namespaces = [
                    "o":  "urn:schemas-microsoft-com:office:office",
                    "ss": "urn:schemas-microsoft-com:office:spreadsheet"
                ]
    if let author = doc.at_xpath("//o:Author", namespaces: namespaces) {
        print(author.text)
    }
}
```

License:
=================
The MIT License. See the LICENSE file for more information.
