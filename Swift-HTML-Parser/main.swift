import Foundation

// sample HTML
let html =
"<html>" +
"<head>" +
"</head>" +
"<body>" +
"  <span class='spantext'>" +
"    <b>Hello World 1</b>" +
"  </span>" +
"  <span class='spantext'>" +
"    <b>Hello World 2</b>" +
"  </span>" +
"  <a href='example.com'>example(English)</a>" +
"  <a href='example.co.jp'>example(JP)</a>" +
"  <div class='val'>value1</div>" +
"  <div class='val'>value2</div>" +
"  <div class='box'>" +
"    <span class='dat'>" +
"      <strong content='2014-12-31'>2014/12/31</strong>" +
"    </span>" +
"    <h2>Hoge</h2>" +
"  </div>" +
"</body>" +
"</html>"


var err : NSError?
var parser     = HTMLParser(html: html, error: &err)
if err != nil {
    println(err)
    exit(1)
}

var bodyNode   = parser.body

if let inputNodes = bodyNode?.findChildTags("b") {
    for node in inputNodes {
        println("Contents: \(node.contents)")
        println("Raw contents: \(node.rawContents)")
    }
}

if let inputNodes = bodyNode?.findChildTags("a") {
    for node in inputNodes {
        println("Contents: \(node.contents)")
        println("Raw contents: \(node.rawContents)")
        println(node.getAttributeNamed("href"))
    }
}

println(bodyNode?.findChildTagAttr("div", attrName: "class", attrValue: "val")?.contents)

if let inputNodes = bodyNode?.findChildTagsAttr("div", attrName: "class", attrValue: "val") {
    for node in inputNodes {
        println("Contents: \(node.contents)")
        println("Raw contents: \(node.rawContents)")
    }
}


if let path = bodyNode?.xpath("//div[@class='box']") {
    for node in path {
        println(node.tagName)
        println(node.xpath("//h2")?[0].contents)
    }
}
