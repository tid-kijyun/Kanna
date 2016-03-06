Kanna(鉋)
=================

Kanna(鉋) is an XML/HTML parser for Mac OS X and iOS. (It was formerly known as Swift-HTML-Parser)

It was inspired by [Nokogiri](https://github.com/sparklemotion/nokogiri)(鋸).

[![Build Status](https://travis-ci.org/tid-kijyun/Kanna.svg?branch=master)](https://travis-ci.org/tid-kijyun/Kanna)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-ios_osx_tvos-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift)
[![Issues](https://img.shields.io/github/issues/tid-kijyun/Kanna.svg?style=flat
           )](https://github.com/tid-kijyun/Kanna/issues)
[![Cocoapod](http://img.shields.io/cocoapods/v/Kanna.svg?style=flat)](http://cocoadocs.org/docsets/Kanna/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Reference Status](https://www.versioneye.com/objective-c/kanna/reference_badge.svg?style=flat)](https://www.versioneye.com/objective-c/kanna/references)


Features:
=================
- [x] XPath 1.0 support for document searching
- [x] CSS3 selector support for document searching
- [x] Support for namespaces
- [x] Comprehensive test suite

Installation:
=================

### Swift 2.x

Three means of installation are supported:

#####CocoaPods
**:warning: CocoaPods (`0.39 or later`) is required.**

Adding it to your `Podfile`:
```
use_frameworks!
pod 'Kanna', '~> 1.0.0'
```

#####Carthage
Adding it to your `Cartfile`:

```
github "tid-kijyun/Kanna" ~> 1.0.0
```

1. In the project settings add `$(SDKROOT)/usr/include/libxml2` to the "header search paths" field

#####Manual Installation
1. Add these files to your project:  
  [Kanna.swift](Source/Kanna.swift)  
  [CSS.swift](Source/CSS.swift)  
  [libxmlHTMLDocument.swift](Source/libxml/libxmlHTMLDocument.swift)  
  [libxmlHTMLNode.swift](Source/libxml/libxmlHTMLNode.swift)  
  [libxmlParserOption.swift](Source/libxml/libxmlParserOption.swift)  
1. Copy this folder to your project:  
  [Modules](Modules)
1. In the project settings add `$(SRCROOT)/YOUR_PROJECT/Modules` to the "Swift Compiler - Search Paths > Import Paths" field
1. In the target settings add `$(SDKROOT)/usr/include/libxml2` to the `Search Paths > Header Search Paths` field

*Note: With manual installation, this library doesn't need to be imported, or namespace-qualified in your code.*

Synopsis:
=================

```swift
import Kanna

let html = "<html>...</html>"

if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
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
if let doc = Kanna.XML(xml: xml, encoding: NSUTF8StringEncoding) {
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
The MIT License. See the LICENSE file for more infomation.
