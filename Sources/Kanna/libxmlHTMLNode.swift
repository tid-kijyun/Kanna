/**@file libxmlHTMLNode.swift

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

/**
libxmlHTMLNode
*/
final class libxmlHTMLNode: XMLElement {
    var text: String? {
        return libxmlGetNodeContent(nodePtr)
    }

    var toHTML: String? {
        let buf = xmlBufferCreate()
        htmlNodeDump(buf, docPtr, nodePtr)
        let html = String(cString: UnsafePointer<UInt8>((buf?.pointee.content)!))
        xmlBufferFree(buf)
        return html
    }

    var toXML: String? {
        let buf = xmlBufferCreate()
        xmlNodeDump(buf, docPtr, nodePtr, 0, 0)
        let html = String(cString: UnsafePointer<UInt8>((buf?.pointee.content)!))
        xmlBufferFree(buf)
        return html
    }

    var innerHTML: String? {
        guard let html = toHTML else { return nil }
        return html
            .replacingOccurrences(of: "</[^>]*>$", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "^<[^>]*>", with: "", options: .regularExpression, range: nil)
    }

    var className: String? {
        self["class"]
    }

    var tagName: String? {
        get {
            guard let name = nodePtr.pointee.name else {
                return nil
            }
            return String(cString: name)
        }
        set {
            if let newValue = newValue {
                xmlNodeSetName(nodePtr, newValue)
            }
        }
    }

    var content: String? {
        get { text }
        set {
            if let newValue = newValue {
                let v = escape(newValue)
                xmlNodeSetContent(nodePtr, v)
            }
        }
    }

    var parent: XMLElement? {
        get {
            libxmlHTMLNode(document: doc, docPtr: docPtr, node: nodePtr.pointee.parent)
        }
        set {
            if let node = newValue as? libxmlHTMLNode {
                node.addChild(self)
            }
        }
    }

    var nextSibling: XMLElement? {
        node(from: xmlNextElementSibling(nodePtr))
    }

    var previousSibling: XMLElement? {
        node(from: xmlPreviousElementSibling(nodePtr))
    }

    private weak var weakDocument: XMLDocument?
    private var document: XMLDocument?
    private var docPtr: htmlDocPtr
    private var nodePtr: xmlNodePtr
    private var doc: XMLDocument? {
        weakDocument ?? document
    }

    subscript(attributeName: String) -> String? {
        get {
            var attr = nodePtr.pointee.properties
            while attr != nil {
                let mem = attr!.pointee
                let prefix = mem.ns.flatMap { $0.pointee.prefix.string }
                let tagName = [prefix, mem.name.string].compactMap { $0 }.joined(separator: ":")
				if attributeName == tagName {
					if let children = mem.children {
						return libxmlGetNodeContent(children)
					} else {
						return ""
					}
				}
                attr = attr!.pointee.next
            }
            return nil
        }
        set(newValue) {
            if let newValue = newValue {
                xmlSetProp(nodePtr, attributeName, newValue)
            } else {
                xmlUnsetProp(nodePtr, attributeName)
            }
        }
    }

    var attributes: [String : String?] {
        var result: [String: String?] = [:]
        var attribute = nodePtr.pointee.properties

        while let attr = attribute {
            let mem = attr.pointee
            let prefix = mem.ns.flatMap { $0.pointee.prefix.string }
            let attributeName = [prefix, mem.name.string].compactMap { $0 }.joined(separator: ":")

            if let children = mem.children {
                result[attributeName] = libxmlGetNodeContent(children)
            }

            attribute = attr.pointee.next
        }

        return result
    }

    init(document: XMLDocument?, docPtr: xmlDocPtr) throws {
        self.weakDocument = document
        self.docPtr       = docPtr
        guard let nodePtr = xmlDocGetRootElement(docPtr) else {
            // Error handling is omitted, and will be added if necessary in the future.
            // e.g: if let error = xmlGetLastError(), error.pointee.code == XML_ERR_DOCUMENT_EMPTY.rawValue
            throw ParseError.Empty
        }
        self.nodePtr = nodePtr
    }

    init(document: XMLDocument?, docPtr: xmlDocPtr, node: xmlNodePtr) {
        self.document = document
        self.docPtr   = docPtr
        self.nodePtr  = node
    }

    // MARK: Searchable
    func xpath(_ xpath: String, namespaces: [String: String]? = nil) -> XPathObject {
        guard let doc = doc else { return .none }
        return XPath(doc: doc, docPtr: docPtr, nodePtr: nodePtr).xpath(xpath, namespaces: namespaces)
    }

    func css(_ selector: String, namespaces: [String: String]? = nil) -> XPathObject {
        guard let doc = doc else { return .none }
        return XPath(doc: doc, docPtr: docPtr, nodePtr: nodePtr).css(selector, namespaces: namespaces)
    }

    func addPrevSibling(_ node: XMLElement) {
        guard let node = node as? libxmlHTMLNode else {
            return
        }
        xmlAddPrevSibling(nodePtr, node.nodePtr)
    }

    func addNextSibling(_ node: XMLElement) {
        guard let node = node as? libxmlHTMLNode else {
            return
        }
        xmlAddNextSibling(nodePtr, node.nodePtr)
    }

    func addChild(_ node: XMLElement) {
        guard let node = node as? libxmlHTMLNode else {
            return
        }
        xmlUnlinkNode(node.nodePtr)
        xmlAddChild(nodePtr, node.nodePtr)
    }

    func removeChild(_ node: XMLElement) {
        guard let node = node as? libxmlHTMLNode else {
            return
        }
        xmlUnlinkNode(node.nodePtr)
        xmlFreeNode(node.nodePtr)
    }

    private func node(from ptr: xmlNodePtr?) -> XMLElement? {
        guard let doc = doc, let nodePtr = ptr else {
            return nil
        }

        return libxmlHTMLNode(document: doc, docPtr: docPtr, node: nodePtr)
    }
}

private func libxmlGetNodeContent(_ nodePtr: xmlNodePtr) -> String? {
    let content = xmlNodeGetContent(nodePtr)
    defer {
        #if swift(>=4.1)
        content?.deallocate()
        #else
        content?.deallocate(capacity: 1)
        #endif
    }
#if swift(>=6.0)
    if let result  = String(validatingCString: UnsafeRawPointer(content!).assumingMemoryBound(to: CChar.self)) {
        return result
    }
#else
    if let result  = String(validatingUTF8: UnsafeRawPointer(content!).assumingMemoryBound(to: CChar.self)) {
        return result
    }
#endif
    return nil
}

let entities = [
    ("&", "&amp;"),
    ("<", "&lt;"),
    (">", "&gt;")
]

private func escape(_ str: String) -> String {
    var newStr = str
    for (unesc, esc) in entities {
        newStr = newStr.replacingOccurrences(of: unesc, with: esc, options: .regularExpression, range: nil)
    }
    return newStr
}

fileprivate extension UnsafePointer<UInt8> {
	var string: String? {
#if swift(>=6.0)
        let string = String(validatingCString: UnsafePointer<CChar>(OpaquePointer(self)))
#else
        let string = String(validatingUTF8: UnsafePointer<CChar>(OpaquePointer(self)))
#endif
		return string
	}
}
