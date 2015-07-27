Kanna(鉋)
=================

Kanna(鉋) is an XML/HTML parser for MacOSX/iOS. (formerly Swift-HTML-Parser)

It was inspired by [Nokogiri](https://github.com/sparklemotion/nokogiri)(鋸).

Features:
=================
- [x] XPath 1.0 support for document searching
- [x] CSS3 selector support for document searching
- [x] Support for namespace
- [x] Comprehensive test suite

Installation:
=================
####Carthage
Adding it to your `Cartfile`:

```
github "tid-kijyun/Kanna" >= 0.1.0
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
