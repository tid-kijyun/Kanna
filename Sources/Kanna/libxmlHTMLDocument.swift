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
import CoreFoundation
import libxml2

extension String.Encoding {
    var IANACharSetName: String? {
        #if os(Linux) && swift(>=4)
        switch self {
        case .ascii:
            return "us-ascii"
        case .iso2022JP:
            return "iso-2022-jp"
        case .isoLatin1:
            return "iso-8859-1"
        case .isoLatin2:
            return "iso-8859-2"
        case .japaneseEUC:
            return "euc-jp"
        case .macOSRoman:
            return "macintosh"
        case .nextstep:
            return "x-nextstep"
        case .nonLossyASCII:
            return nil
        case .shiftJIS:
            return "cp932"
        case .symbol:
            return "x-mac-symbol"
        case .unicode:
            return "utf-16"
        case .utf16:
            return "utf-16"
        case .utf16BigEndian:
            return "utf-16be"
        case .utf32:
            return "utf-32"
        case .utf32BigEndian:
            return "utf-32be"
        case .utf32LittleEndian:
            return "utf-32le"
        case .utf8:
            return "utf-8"
        case .windowsCP1250:
            return "windows-1250"
        case .windowsCP1251:
            return "windows-1251"
        case .windowsCP1252:
            return "windows-1252"
        case .windowsCP1253:
            return "windows-1253"
        case .windowsCP1254:
            return "windows-1254"
        default:
            return nil
        }
        #elseif os(Linux) && swift(>=3)
        switch self {
        case String.Encoding.ascii:
            return "us-ascii"
        case String.Encoding.iso2022JP:
            return "iso-2022-jp"
        case String.Encoding.isoLatin1:
            return "iso-8859-1"
        case String.Encoding.isoLatin2:
            return "iso-8859-2"
        case String.Encoding.japaneseEUC:
            return "euc-jp"
        case String.Encoding.macOSRoman:
            return "macintosh"
        case String.Encoding.nextstep:
            return "x-nextstep"
        case String.Encoding.nonLossyASCII:
            return nil
        case String.Encoding.shiftJIS:
            return "cp932"
        case String.Encoding.symbol:
            return "x-mac-symbol"
        case String.Encoding.unicode:
            return "utf-16"
        case String.Encoding.utf16:
            return "utf-16"
        case String.Encoding.utf16BigEndian:
            return "utf-16be"
        case String.Encoding.utf32:
            return "utf-32"
        case String.Encoding.utf32BigEndian:
            return "utf-32be"
        case String.Encoding.utf32LittleEndian:
            return "utf-32le"
        case String.Encoding.utf8:
            return "utf-8"
        case String.Encoding.windowsCP1250:
            return "windows-1250"
        case String.Encoding.windowsCP1251:
            return "windows-1251"
        case String.Encoding.windowsCP1252:
            return "windows-1252"
        case String.Encoding.windowsCP1253:
            return "windows-1253"
        case String.Encoding.windowsCP1254:
            return "windows-1254"
        default:
            return nil
        }
        #else
        let cfenc = CFStringConvertNSStringEncodingToEncoding(rawValue)
        guard let cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc) else {
            return nil
        }
        return String(describing: cfencstr)
        #endif
    }
}

/*
libxmlHTMLDocument
*/
final class libxmlHTMLDocument: HTMLDocument {
    private var docPtr: htmlDocPtr?
    private var rootNode: XMLElement?
    private var html: String
    private var url: String?
    private var encoding: String.Encoding

    var text: String? { rootNode?.text }

    var toHTML: String? {
        let buf       = xmlBufferCreate()
        let outputBuf = xmlOutputBufferCreateBuffer(buf, nil)
        defer {
            xmlOutputBufferClose(outputBuf)
            xmlBufferFree(buf)
        }

        htmlDocContentDumpOutput(outputBuf, docPtr, nil)
        let html = String(cString: UnsafePointer(xmlOutputBufferGetContent(outputBuf)))
        return html
    }

    var toXML: String? {
        var buf: UnsafeMutablePointer<xmlChar>?
        let size: UnsafeMutablePointer<Int32>? = nil
        defer {
            xmlFree(buf)
        }

        xmlDocDumpMemory(docPtr, &buf, size)
        let html = String(cString: UnsafePointer<UInt8>(buf!))
        return html
    }

    var innerHTML: String? { rootNode?.innerHTML }

    var className: String? { nil }

    var tagName: String? {
        get { nil }
        set {}
    }

    var content: String? {
        get { text }
        set { rootNode?.content = newValue }
    }

    var namespaces: [Namespace] { getNamespaces(docPtr: docPtr) }

    init(html: String, url: String?, encoding: String.Encoding, option: UInt) throws {
        self.html     = html
        self.url      = url
        self.encoding = encoding

        guard html.lengthOfBytes(using: encoding) > 0 else {
            throw ParseError.Empty
        }

        guard let charsetName = encoding.IANACharSetName,
            let cur = html.cString(using: encoding) else {
            throw ParseError.EncodingMismatch
        }

        let url: String = ""
        docPtr = cur.withUnsafeBytes { htmlReadDoc($0.bindMemory(to: xmlChar.self).baseAddress!, url, charsetName, CInt(option)) }
        guard let docPtr = docPtr else {
            throw ParseError.EncodingMismatch
        }

        rootNode = libxmlHTMLNode(document: self, docPtr: docPtr)
    }

    deinit {
        xmlFreeDoc(docPtr)
    }

    var title: String? { at_xpath("//title")?.text }
    var head: XMLElement? { at_xpath("//head") }
    var body: XMLElement? { at_xpath("//body") }

    func xpath(_ xpath: String, namespaces: [String: String]? = nil) -> XPathObject {
        guard let docPtr = docPtr else { return .none }
        return XPath(doc: self, docPtr: docPtr).xpath(xpath, namespaces: namespaces)
    }

    func css(_ selector: String, namespaces: [String: String]? = nil) -> XPathObject {
        guard let docPtr = docPtr else { return .none }
        return XPath(doc: self, docPtr: docPtr).css(selector, namespaces: namespaces)
    }
}

/*
libxmlXMLDocument
*/
final class libxmlXMLDocument: XMLDocument {
    private var docPtr: xmlDocPtr?
    private var rootNode: XMLElement?
    private var xml: String
    private var url: String?
    private var encoding: String.Encoding

    var text: String? { rootNode?.text }

    var toHTML: String? {
        let buf       = xmlBufferCreate()
        let outputBuf = xmlOutputBufferCreateBuffer(buf, nil)
        defer {
            xmlOutputBufferClose(outputBuf)
            xmlBufferFree(buf)
        }

        htmlDocContentDumpOutput(outputBuf, docPtr, nil)
        let html = String(cString: UnsafePointer(xmlOutputBufferGetContent(outputBuf)))
        return html
    }

    var toXML: String? {
        var buf: UnsafeMutablePointer<xmlChar>?
        let size: UnsafeMutablePointer<Int32>? = nil
        defer {
            xmlFree(buf)
        }

        xmlDocDumpMemory(docPtr, &buf, size)
        let html = String(cString: UnsafePointer<UInt8>(buf!))
        return html
    }

    var innerHTML: String? { rootNode?.innerHTML }

    var className: String? { nil }

    var tagName: String? {
        get { nil }
        set {}
    }

    var content: String? {
        get { text }
        set { rootNode?.content = newValue }
    }

    var namespaces: [Namespace] { getNamespaces(docPtr: docPtr) }

    init(xml: String, url: String?, encoding: String.Encoding, option: UInt) throws {
        self.xml      = xml
        self.url      = url
        self.encoding = encoding

        if xml.isEmpty {
            throw ParseError.Empty
        }

        guard let charsetName = encoding.IANACharSetName,
            let cur = xml.cString(using: encoding) else {
                throw ParseError.EncodingMismatch
        }
        let url: String = ""
        docPtr   = cur.withUnsafeBytes { xmlReadDoc($0.bindMemory(to: xmlChar.self).baseAddress!, url, charsetName, CInt(option)) }
        rootNode = libxmlHTMLNode(document: self, docPtr: docPtr!)
    }

    deinit {
        xmlFreeDoc(docPtr)
    }

    func xpath(_ xpath: String, namespaces: [String: String]? = nil) -> XPathObject {
        guard let docPtr = docPtr else { return .none }
        return XPath(doc: self, docPtr: docPtr).xpath(xpath, namespaces: namespaces)
    }

    func css(_ selector: String, namespaces: [String: String]? = nil) -> XPathObject {
        guard let docPtr = docPtr else { return .none }
        return XPath(doc: self, docPtr: docPtr).css(selector, namespaces: namespaces)
    }
}

struct XPath {
    private let doc: XMLDocument
    private var docPtr: xmlDocPtr
    private var nodePtr: xmlNodePtr?
    private var isRoot: Bool {
        guard let nodePtr = nodePtr else { return true }
        return xmlDocGetRootElement(docPtr) == nodePtr
    }

    init(doc: XMLDocument, docPtr: xmlDocPtr, nodePtr: xmlNodePtr? = nil) {
        self.doc = doc
        self.docPtr = docPtr
        self.nodePtr = nodePtr
    }

    func xpath(_ xpath: String, namespaces: [String: String]? = nil) -> XPathObject {
        guard let ctxt = xmlXPathNewContext(docPtr) else { return .none }
        defer { xmlXPathFreeContext(ctxt) }

        if let nsDictionary = namespaces {
            for (ns, name) in nsDictionary {
                xmlXPathRegisterNs(ctxt, ns, name)
            }
        }

        if let node = nodePtr {
            ctxt.pointee.node = node
        }

        guard let result = xmlXPathEvalExpression(adoptXpath(xpath), ctxt) else { return .none }
        defer { xmlXPathFreeObject(result) }

        return XPathObject(document: doc, docPtr: docPtr, object: result.pointee)
    }

    func css(_ selector: String, namespaces: [String: String]? = nil) -> XPathObject {
        if let xpath = try? CSS.toXPath(selector, isRoot: isRoot) {
            return self.xpath(xpath, namespaces: namespaces)
        }
        return .none
    }

    private func adoptXpath(_ xpath: String) -> String {
        guard !isRoot else { return xpath }
        if xpath.hasPrefix("/") {
            return "." + xpath
        } else {
            return xpath
        }
    }
}

private func getNamespaces(docPtr: xmlDocPtr?) -> [Namespace] {
    let rootNode = xmlDocGetRootElement(docPtr)
    guard let ns = xmlGetNsList(docPtr, rootNode) else {
        return []
    }

    var result: [Namespace] = []
    var next = ns.pointee
    while next != nil {
        if let namePtr = next?.pointee.href {
            let prefixPtr = next?.pointee.prefix
            let prefix = prefixPtr == nil ? "" : String(cString: UnsafePointer<UInt8>(prefixPtr!))
            let name = String(cString: UnsafePointer<UInt8>(namePtr))
            result.append(Namespace(prefix: prefix, name: name))
        }
        next = next?.pointee.next
    }
    return result
}
