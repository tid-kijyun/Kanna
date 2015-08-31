/**@file libxmlHTMLDocument.swift

Kanna

Copyright (c) 2015 Atsushi Kiwaki (@_tid_)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
import Foundation

/*
libxmlHTMLDocument
*/
internal final class libxmlHTMLDocument: HTMLDocument {
    private var docPtr:   htmlDocPtr = nil
    private var rootNode: XMLElement?
    private var html: String
    private var url:  String?
    private var encoding: UInt
    
    var text: String? {
        return rootNode?.text
    }
    
    var toHTML: String? {
        return html
    }
    
    var innerHTML: String? {
        return rootNode?.innerHTML
    }
    
    var className: String? {
        return nil
    }
    
    var tagName:   String? {
        return nil
    }
    
    init?(html: String, url: String?, encoding: UInt, option: UInt) {
        self.html = html
        self.url  = url
        self.encoding = encoding
        
        if html.lengthOfBytesUsingEncoding(encoding) <= 0 {
            return nil
        }
        let cfenc : CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(encoding)
        let cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc)
        
        if let cur = html.cStringUsingEncoding(encoding) {
            let url : String = ""
            docPtr = htmlReadDoc(UnsafePointer<xmlChar>(cur), url, String(cfencstr), CInt(option))
            rootNode  = libxmlHTMLNode(docPtr: docPtr)
        } else {
            return nil
        }
    }
    
    deinit {
        xmlFreeDoc(self.docPtr)
    }

    var title: String? { return at_xpath("//title")?.text }
    var head: XMLElement? { return at_xpath("//head") }
    var body: XMLElement? { return at_xpath("//body") }
    
    func xpath(xpath: String, namespaces: [String:String]?) -> XMLNodeSet {
        return rootNode?.xpath(xpath, namespaces: namespaces) ?? XMLNodeSet()
    }
    
    func xpath(xpath: String) -> XMLNodeSet {
        return self.xpath(xpath, namespaces: nil)
    }
    
    func at_xpath(xpath: String, namespaces: [String:String]?) -> XMLElement? {
        return rootNode?.at_xpath(xpath, namespaces: namespaces)
    }
    
    func at_xpath(xpath: String) -> XMLElement? {
        return self.at_xpath(xpath, namespaces: nil)
    }
    
    func css(selector: String, namespaces: [String:String]?) -> XMLNodeSet {
        return rootNode?.css(selector, namespaces: namespaces) ?? XMLNodeSet()
    }
    
    func css(selector: String) -> XMLNodeSet {
        return self.css(selector, namespaces: nil)
    }
    
    func at_css(selector: String, namespaces: [String:String]?) -> XMLElement? {
        return rootNode?.at_css(selector, namespaces: namespaces)
    }
    
    func at_css(selector: String) -> XMLElement? {
        return self.at_css(selector, namespaces: nil)
    }
}

/*
libxmlXMLDocument
*/
internal final class libxmlXMLDocument: XMLDocument {
    private var docPtr:   xmlDocPtr = nil
    private var rootNode: XMLElement?
    private var xml: String
    private var url: String?
    private var encoding: UInt
    
    var text: String? {
        return rootNode?.text
    }
    
    var toHTML: String? {
        return xml
    }
    
    var innerHTML: String? {
        return rootNode?.innerHTML
    }
    
    var className: String? {
        return nil
    }
    
    var tagName:   String? {
        return nil
    }
    
    init?(xml: String, url: String?, encoding: UInt, option: UInt) {
        self.xml  = xml
        self.url  = url
        self.encoding = encoding
        
        if xml.lengthOfBytesUsingEncoding(encoding) <= 0 {
            return nil
        }
        let cfenc : CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(encoding)
        let cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc)
        
        if let cur = xml.cStringUsingEncoding(encoding) {
            let url : String = ""
            docPtr = xmlReadDoc(UnsafePointer<xmlChar>(cur), url, String(cfencstr), CInt(option))
            rootNode  = libxmlHTMLNode(docPtr: docPtr)
        } else {
            return nil
        }
    }
    
    func xpath(xpath: String, namespaces: [String:String]?) -> XMLNodeSet {
        return rootNode?.xpath(xpath, namespaces: namespaces) ?? XMLNodeSet()
    }
    
    func xpath(xpath: String) -> XMLNodeSet {
        return self.xpath(xpath, namespaces: nil)
    }
    
    func at_xpath(xpath: String, namespaces: [String:String]?) -> XMLElement? {
        return rootNode?.at_xpath(xpath, namespaces: namespaces)
    }
    
    func at_xpath(xpath: String) -> XMLElement? {
        return self.at_xpath(xpath, namespaces: nil)
    }
    
    func css(selector: String, namespaces: [String:String]?) -> XMLNodeSet {
        return rootNode?.css(selector, namespaces: namespaces) ?? XMLNodeSet()
    }
    
    func css(selector: String) -> XMLNodeSet {
        return self.css(selector, namespaces: nil)
    }
    
    func at_css(selector: String, namespaces: [String:String]?) -> XMLElement? {
        return rootNode?.at_css(selector, namespaces: namespaces)
    }
    
    func at_css(selector: String) -> XMLElement? {
        return self.at_css(selector, namespaces: nil)
    }
}