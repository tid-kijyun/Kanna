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

/**
libxmlHTMLNode
*/
internal final class libxmlHTMLNode: XMLElement {
    var text: String? {
        if nodePtr != nil {
            return String.fromCString(UnsafePointer(xmlNodeGetContent(nodePtr)))
        }
        return nil
    }
    
    var toHTML: String? {
        let buf = xmlBufferCreate()
        htmlNodeDump(buf, docPtr, nodePtr)
        let html = String.fromCString(UnsafePointer(buf.memory.content))
        xmlBufferFree(buf)
        return html
    }
    
    var innerHTML: String? {
        var html: String = ""
        html += libxmlGetNodeText(nodePtr.memory.children)
        html += self.xpath(".//*").first?.toHTML ?? ""
        html += libxmlGetNodeText(xmlGetLastChild(nodePtr))
        return html
    }
    
    var className: String? {
        return self["class"]
    }
    
    var tagName:   String? {
        if nodePtr != nil {
            return String.fromCString(UnsafePointer(nodePtr.memory.name))
        }
        return nil
    }
    
    private var docPtr:  htmlDocPtr = nil
    private var nodePtr: xmlNodePtr = nil
    private var isRoot:  Bool       = false
    
    
    subscript(attributeName: String) -> String? {
        for var attr = nodePtr.memory.properties; attr != nil; attr = attr.memory.next {
            let mem = attr.memory
            if let tagName = String.fromCString(UnsafePointer(mem.name)) {
                if attributeName == tagName {
                    return String.fromCString(UnsafePointer(xmlNodeGetContent(mem.children)))
                }
            }
        }
        return nil
    }
    
    init(docPtr: xmlDocPtr) {
        self.docPtr  = docPtr
        self.nodePtr = xmlDocGetRootElement(docPtr)
        self.isRoot  = true
    }
    
    init(docPtr: xmlDocPtr, node: xmlNodePtr) {
        self.docPtr  = docPtr
        self.nodePtr = node
    }
    
    // MARK: Searchable
    func xpath(xpath: String, namespaces: [String:String]?) -> XMLNodeSet {
        let ctxt = xmlXPathNewContext(docPtr)
        if ctxt == nil {
            return XMLNodeSet()
        }
        ctxt.memory.node = nodePtr
        
        if let nsDictionary = namespaces {
            for (ns, name) in nsDictionary {
                xmlXPathRegisterNs(ctxt, ns, name)
            }
        }
        
        let result = xmlXPathEvalExpression(xpath, ctxt)
        xmlXPathFreeContext(ctxt)
        if result == nil {
            return XMLNodeSet()
        }
        
        let nodeSet = result.memory.nodesetval
        if nodeSet == nil || nodeSet.memory.nodeNr == 0 || nodeSet.memory.nodeTab == nil {
            return XMLNodeSet()
        }
        
        var nodes : [XMLElement] = []
        let size = Int(nodeSet.memory.nodeNr)
        for var i = 0; i < size; ++i {
            let node = nodeSet.memory.nodeTab[i]
            let htmlNode = libxmlHTMLNode(docPtr: docPtr, node: node)
            nodes.append(htmlNode)
        }
        
        return XMLNodeSet(nodes: nodes)
    }
    
    func xpath(xpath: String) -> XMLNodeSet {
        return self.xpath(xpath, namespaces: nil)
    }
    
    func at_xpath(xpath: String, namespaces: [String:String]?) -> XMLElement? {
        return self.xpath(xpath, namespaces: namespaces).first
    }
    
    func at_xpath(xpath: String) -> XMLElement? {
        return self.at_xpath(xpath, namespaces: nil)
    }
    
    func css(selector: String, namespaces: [String:String]?) -> XMLNodeSet {
        if let xpath = CSS.toXPath(selector) {
            if isRoot {
                return self.xpath(xpath, namespaces: namespaces)
            } else {
                return self.xpath("." + xpath, namespaces: namespaces)
            }
        }
        return XMLNodeSet()
    }
    
    func css(selector: String) -> XMLNodeSet {
        return self.css(selector, namespaces: nil)
    }
    
    func at_css(selector: String, namespaces: [String:String]?) -> XMLElement? {
        return self.css(selector, namespaces: namespaces).first
    }
    
    func at_css(selector: String) -> XMLElement? {
        return self.css(selector, namespaces: nil).first
    }
}

private func libxmlGetNodeText(nodePtr: xmlNodePtr) -> String {
    let type = nodePtr.memory.type
    if type.rawValue == XML_TEXT_NODE.rawValue,
        let text = String.fromCString(UnsafePointer(xmlNodeGetContent(nodePtr))) {
            return text
    }
    return ""
}
