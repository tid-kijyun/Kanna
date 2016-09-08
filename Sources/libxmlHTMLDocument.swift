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
import libxml2

/*
libxmlHTMLDocument
*/
internal final class libxmlHTMLDocument: HTMLDocument {
    private var docPtr:   htmlDocPtr? = nil
    private var rootNode: XMLElement?
    private var html: String
    private var url:  String?
    private var encoding: String.Encoding
    
    var text: String? {
        return rootNode?.text
    }

    var toHTML: String? {
        let buf = xmlBufferCreate()
        defer {
            xmlBufferFree(buf)
        }

        let outputBuf = xmlOutputBufferCreateBuffer(buf, nil)
        htmlDocContentDumpOutput(outputBuf, docPtr, nil)
        let html = String(cString: UnsafePointer(xmlOutputBufferGetContent(outputBuf)))
        return html
    }

    var toXML: String? {
        var buf: UnsafeMutablePointer<xmlChar>? = nil
        let size: UnsafeMutablePointer<Int32>? = nil
        defer {
            xmlFree(buf)
        }

        xmlDocDumpMemory(docPtr, &buf, size)
        let html = String(cString: UnsafePointer(buf!))
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
    
    init?(html: String, url: String?, encoding: String.Encoding, option: UInt) {
        self.html = html
        self.url  = url
        self.encoding = encoding
        
        if html.lengthOfBytes(using: encoding) <= 0 {
            return nil
        }
        let cfenc : CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)
        let cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc) as? String
        
        if let cur = html.cString(using: encoding) {
            let url : String = ""
            docPtr = htmlReadDoc(UnsafeRawPointer(cur).assumingMemoryBound(to: xmlChar.self), url, cfencstr ?? "", CInt(option))
            rootNode  = libxmlHTMLNode(docPtr: docPtr!)
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
    
    func xpath(_ xpath: String, namespaces: [String:String]?) -> XPathObject {
        return rootNode?.xpath(xpath, namespaces: namespaces) ?? XPathObject.none
    }
    
    func xpath(_ xpath: String) -> XPathObject {
        return self.xpath(xpath, namespaces: nil)
    }
    
    func at_xpath(_ xpath: String, namespaces: [String:String]?) -> XMLElement? {
        return rootNode?.at_xpath(xpath, namespaces: namespaces)
    }
    
    func at_xpath(_ xpath: String) -> XMLElement? {
        return self.at_xpath(xpath, namespaces: nil)
    }
    
    func css(_ selector: String, namespaces: [String:String]?) -> XPathObject {
        return rootNode?.css(selector, namespaces: namespaces) ?? XPathObject.none
    }
    
    func css(_ selector: String) -> XPathObject {
        return self.css(selector, namespaces: nil)
    }
    
    func at_css(_ selector: String, namespaces: [String:String]?) -> XMLElement? {
        return rootNode?.at_css(selector, namespaces: namespaces)
    }
    
    func at_css(_ selector: String) -> XMLElement? {
        return self.at_css(selector, namespaces: nil)
    }
}

/*
libxmlXMLDocument
*/
internal final class libxmlXMLDocument: XMLDocument {
    private var docPtr:   xmlDocPtr? = nil
    private var rootNode: XMLElement?
    private var xml: String
    private var url: String?
    private var encoding: String.Encoding
    
    var text: String? {
        return rootNode?.text
    }
    
    var toHTML: String? {
        let buf = xmlBufferCreate()
        defer {
            xmlBufferFree(buf)
        }

        let outputBuf = xmlOutputBufferCreateBuffer(buf, nil)
        htmlDocContentDumpOutput(outputBuf, docPtr, nil)
        let html = String(cString: UnsafePointer(xmlOutputBufferGetContent(outputBuf)))
        return html
    }

    var toXML: String? {
        var buf: UnsafeMutablePointer<xmlChar>? = nil
        let size: UnsafeMutablePointer<Int32>? = nil
        defer {
            xmlFree(buf)
        }

        xmlDocDumpMemory(docPtr, &buf, size)
        let html = String(cString: UnsafePointer(buf!))
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
    
    init?(xml: String, url: String?, encoding: String.Encoding, option: UInt) {
        self.xml  = xml
        self.url  = url
        self.encoding = encoding
        
        if xml.lengthOfBytes(using: encoding) <= 0 {
            return nil
        }
        let cfenc : CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)
        let cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc)
        
        if let cur = xml.cString(using: encoding) {
            let url : String = ""
            docPtr = xmlReadDoc(UnsafeRawPointer(cur).assumingMemoryBound(to: xmlChar.self), url, (cfencstr as? String) ?? "", CInt(option))
            rootNode  = libxmlHTMLNode(docPtr: docPtr!)
        } else {
            return nil
        }
    }

    deinit {
        xmlFreeDoc(self.docPtr)
    }
    
    func xpath(_ xpath: String, namespaces: [String:String]?) -> XPathObject {
        return rootNode?.xpath(xpath, namespaces: namespaces) ?? XPathObject.none
    }
    
    func xpath(_ xpath: String) -> XPathObject {
        return self.xpath(xpath, namespaces: nil)
    }
    
    func at_xpath(_ xpath: String, namespaces: [String:String]?) -> XMLElement? {
        return rootNode?.at_xpath(xpath, namespaces: namespaces)
    }
    
    func at_xpath(_ xpath: String) -> XMLElement? {
        return self.at_xpath(xpath, namespaces: nil)
    }
    
    func css(_ selector: String, namespaces: [String:String]?) -> XPathObject {
        return rootNode?.css(selector, namespaces: namespaces) ?? XPathObject.none
    }
    
    func css(_ selector: String) -> XPathObject {
        return self.css(selector, namespaces: nil)
    }
    
    func at_css(_ selector: String, namespaces: [String:String]?) -> XMLElement? {
        return rootNode?.at_css(selector, namespaces: namespaces)
    }
    
    func at_css(_ selector: String) -> XMLElement? {
        return self.at_css(selector, namespaces: nil)
    }
}
