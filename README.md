Kanna(鉋)
=================

Kanna(鉋) is an XML/HTML parser for MacOSX/iOS. (formerly Swift-HTML-Parser)

It was inspired by [Nokogiri](https://github.com/sparklemotion/nokogiri)(鋸).

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
- [x] Support for namespace
- [x] Comprehensive test suite

Installation:
=================

### Swift2
#####Cocoapods
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

#####Munually
1. Add files to your project:  
  [Kanna.swift](Source/Kanna.swift)  
  [CSS.swift](Source/CSS.swift)  
  [libxmlHTMLDocument.swift](Source/libxml/libxmlHTMLDocument.swift)  
  [libxmlHTMLNode.swift](Source/libxml/libxmlHTMLNode.swift)  
  [libxmlParserOption.swift](Source/libxml/libxmlParserOption.swift)  
1. Copy folder to your project:  
  [Modules](Modules)
1. In the project settings add `$(SRCROOT)/YOUR_PROJECT/Modules` to the "Swift Compiler - Search Paths > Import Paths" field
1. In the project settings add `$(SDKROOT)/usr/include/libxml2` to the "header search paths" field
1. In the project settings add `-lxml2` to the "Linking > Other Linker Flags" field

*Note: For manually, this library don't need import and namespace in your code.*

### Swift1.2（deprecated）
#####Cocoapods
Adding it to your `Podfile`:
```
use_frameworks!
pod 'Kanna', '~> 0.1.5'
```

#####Carthage
Adding it to your `Cartfile`:

```
github "tid-kijyun/Kanna" ~> 0.1.5
```


Synopsis:
=================

```swift
import Kanna

let html = "<html>...</html>"

if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
    println(doc.title)
    
    // Search for nodes by CSS
    for link in doc.css("a, link") {
        println(link.text)
        println(link["href"])
    }
    
    // Search for nodes by XPath
    for link in doc.xpath("//a | //link") {
        println(link.text)
        println(link["href"])
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
        println(author.text)
    }
}
```

Migration guide: (from Swift-HTML-Parser)
=================

### Initialize
```swift
// Swift-HTML-Parser
var err: NSError?
var parser = HTMLParser(html: html, error: &err)

// New: Kanna
if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
}
```
### Search for node
#### Search for nodes by tag
```swift
// Swift-HTML-Parser
if let nodes = parser.body?.findChildTags("div") {
    for node in nodes {
        println(node.contents)
    }
}

// NEW: Kanna
for node in doc.css("div") {
    println(doc.text)
}
```

#### Search for nodes by XPath
```swift
// Swift-HTML-Parser
if let nodes = parser.body?.xpath("//div") {
    for node in nodes {
        println(node.contents)
    }
}

// New: Kanna
for node in doc.xpath("//div") {
    println(node.text)
}
```

#### Search for nodes by CSS
```swift
// Swift-HTML-Parser
if let nodes = parser.body?.css("li:nth-child(2n)") {
    for node in nodes {
        println(node.contents)
    }
}

// New: Kanna
for node in doc.css("li:nth-child(2n)") {
    print(node.text)
}
```

#### Search for first node
```swift
// Swift-HTML-Parser
if let node = parser.body?.findChildTag("div") {
    println(node.contents)
}

// New: Kanna
if let node = doc.at_css("div") {
    println(node.text)
}
```

### Get contents

#### Get contents
```swift
// Swift-HTML-Parser
node.contents

// New: Kanna
node.text
```

#### Get attribute
```swift
// Swift-HTML-Parser
node.getAttributeNamed("href")

// New: Kanna
node["href"]
```

#### Get raw contents
```swift
// Swift-HTML-Parser
node.rawContents

// New: Kanna
node.innerHTML
```

Lisense:
=================
The MIT License. See the LICENSE file for more infomation.
