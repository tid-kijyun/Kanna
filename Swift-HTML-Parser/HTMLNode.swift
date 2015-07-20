/**@file
* @brief Swift-HTML-Parser
* @author _tid_
*/
import Foundation

/**
* HTMLNode
*/
public class HTMLNode {
    public enum HTMLNodeType : String {
        case HTMLUnkownNode     = ""
        case HTMLHrefNode       = "href"
        case HTMLTextNode       = "text"
        case HTMLCodeNode       = "code"
        case HTMLSpanNode       = "span"
        case HTMLPNode          = "p"
        case HTMLLiNode         = "li"
        case HTMLUiNode         = "ui"
        case HTMLImageNode      = "image"
        case HTMLOlNode         = "ol"
        case HTMLStrongNode     = "strong"
        case HTMLPreNode        = "pre"
        case HTMLBlockQuoteNode = "blockquote"
    }
    
    private var doc       : htmlDocPtr
    private var node      : xmlNode?
    private var pointer : xmlNodePtr
    private let nodeType  : HTMLNodeType
    
    /**
    * 親ノード
    */
    private var parent    : HTMLNode? {
        if let p = self.node?.parent {
            return HTMLNode(doc: self.doc, node: p)
        }
        return nil
    }
    
    /**
    * 次ノード
    */
    private var next : HTMLNode? {
        if let n : UnsafeMutablePointer<xmlNode> = node?.next {
            if n != nil {
                return HTMLNode(doc: doc, node: n)
            }
        }
        return nil
    }
    
    /**
    * 子ノード
    */
    private var child     : HTMLNode? {
        if let c = node?.children {
            if c != nil {
                return HTMLNode(doc: doc, node: c)
            }
        }
        return nil
    }
    
    /**
    * クラス名
    */
    public var className : String {
        return getAttributeNamed("class")
    }
    
    /**
    * タグ名
    */
    public var tagName : String {
        return HTMLNode.GetTagName(self.node)
    }
    
    private static func GetTagName(node: xmlNode?) -> String {
        if let n = node {
            return ConvXmlCharToString(n.name)
        }
        return ""
    }
    
    /**
    * コンテンツ
    */
    public var contents : String {
        if node != nil {
            return ConvXmlCharToString(xmlNodeGetContent(pointer))
        }
        return ""
    }
    
    public var rawContents : String {
        if node != nil {
            return rawContentsOfNode(self.node!, self.pointer)
        }
        return ""
    }
    
    /**
    * Initializer
    * @param[in] doc xmlDoc
    */
    public init(doc: htmlDocPtr = nil) {
        self.doc  = doc
        var node = xmlDocGetRootElement(doc)
        self.pointer = node
        self.nodeType = .HTMLUnkownNode
        if node != nil {
            self.node = node.memory
        }
    }
    
    private init(doc: htmlDocPtr, node: UnsafePointer<xmlNode>) {
        self.doc  = doc
        self.node = node.memory
        self.pointer = xmlNodePtr(node)
        if let type = HTMLNodeType(rawValue: HTMLNode.GetTagName(self.node)) {
            self.nodeType = type
        } else {
            self.nodeType = .HTMLUnkownNode
        }
    }
    
    /**
    * 属性名を取得する
    * @param[in] name 属性
    * @return 属性名
    */
    public func getAttributeNamed(name: String) -> String {
        for var attr : xmlAttrPtr = node!.properties; attr != nil; attr = attr.memory.next {
            var mem = attr.memory
            
            if name == ConvXmlCharToString(mem.name) {
                return ConvXmlCharToString(xmlNodeGetContent(mem.children))
            }
        }
        
        return ""
    }
    
    /**
    * タグ名に一致する全ての子ノードを探す
    * @param[in] tagName タグ名
    * @return 子ノードの配列
    */
    public func findChildTags(tagName: String) -> [HTMLNode] {
        var nodes : [HTMLNode] = []
        
        return findChildTags(tagName, node: self.child, retAry: &nodes)
    }
    
    private func findChildTags(tagName: String, node: HTMLNode?, inout retAry: [HTMLNode] ) -> [HTMLNode] {
        if let n = node {
            for curNode in n {
                if curNode.tagName == tagName {
                    retAry.append(curNode)
                }
                
                findChildTags(tagName, node: curNode.child, retAry: &retAry)
            }
        }
        return retAry
    }
    
    /**
    * タグ名で子ノードを探す
    * @param[in] tagName タグ名
    * @return 子ノード。見つからなければnil
    */
    public func findChildTag(tagName: String) -> HTMLNode? {
        return findChildTag(tagName, node: self)
    }
    
    private func findChildTag(tagName: String, node: HTMLNode?) -> HTMLNode? {
        if let nd = node {
            for curNode in nd {
                if tagName == curNode.tagName {
                    return curNode
                }
                
                if let c = curNode.child {
                    if let n = findChildTag(tagName, node: c) {
                        return n
                    }
                }
            }
        }
        
        return nil
    }
    
    //------------------------------------------------------
    
    public func findChildTagsAttr(tagName: String, attrName : String, attrValue : String) -> [HTMLNode] {
        var nodes : [HTMLNode] = []
        
        return findChildTagsAttr(tagName, attrName : attrName, attrValue : attrValue, node: self.child, retAry: &nodes)
    }
    
    private func findChildTagsAttr(tagName: String, attrName : String, attrValue : String, node: HTMLNode?, inout retAry: [HTMLNode] ) -> [HTMLNode] {
        if let n = node {
            for curNode in n {
                if curNode.tagName == tagName && curNode.getAttributeNamed(attrName) == attrValue {
                    retAry.append(curNode)
                }
                
                findChildTagsAttr(tagName, attrName : attrName, attrValue : attrValue, node: curNode.child, retAry: &retAry)
            }
        }
        return retAry
    }
    
    public func findChildTagAttr(tagName : String, attrName : String, attrValue : String) -> HTMLNode?
    {
        return findChildTagAttr(tagName, attrName : attrName, attrValue : attrValue, node: self)
    }
    
    private func findChildTagAttr(tagName : String, attrName : String, attrValue : String, node: HTMLNode?) -> HTMLNode?
    {
        if let nd = node {
            for curNode in nd {
                if tagName == curNode.tagName && curNode.getAttributeNamed(attrName) == attrValue {
                    return curNode
                }
                
                if let c = curNode.child {
                    if let n = findChildTagAttr(tagName,attrName: attrName,attrValue: attrValue, node: c) {
                        return n
                    }
                }
            }
        }
        
        return nil
    }
    /**
    * Find node by id (id has to be used properly it is a uniq attribute)
    * @param[in] id String
    * @return HTMLNode
    */
    public func findNodeById(id: String) -> HTMLNode? {
        return findNodeById(id, node: self)
    }
    
    private func findNodeById(id: String, node: HTMLNode?) -> HTMLNode? {
        if let nd = node {
            for curNode in nd {
                if id == curNode.getAttributeNamed("id") {
                    return curNode
                }
                
                if let c = curNode.child {
                    if let n = findNodeById(id, node: c) {
                        return n
                    }
                }
            }
        }
        
        return nil
    }
    
    /**
    * xpathで子ノードを探す
    * @param[in] xpath xpath
    * @return 子ノード。見つからなければnil
    */
    public func xpath(xpath: String) -> [HTMLNode]? {
        let ctxt = xmlXPathNewContext(self.doc)
        if ctxt == nil {
            return nil
        }
        ctxt.memory.node = pointer
        let result = xmlXPathEvalExpression(xpath, ctxt)
        xmlXPathFreeContext(ctxt)
        if result == nil {
            return nil
        }
        
        let nodeSet = result.memory.nodesetval
        if nodeSet == nil || nodeSet.memory.nodeNr == 0 || nodeSet.memory.nodeTab == nil {
            return nil
        }
        
        var nodes : [HTMLNode] = []
        let size = Int(nodeSet.memory.nodeNr)
        for var i = 0; i < size; ++i {
            let n = nodeSet.memory
            let node = nodeSet.memory.nodeTab[i]
            let htmlNode = HTMLNode(doc: self.doc, node: node)
            nodes.append(htmlNode)
        }
        
        return nodes
    }
    
    /**
    *
    *
    */
    public func css(selector: String) -> [HTMLNode]? {
        if let xpath = CSS.toXPath(selector) {
            return self.xpath(xpath)
        }
        return nil
    }
}

extension HTMLNode : SequenceType {
    public func generate() -> HTMLNodeGenerator {
        return HTMLNodeGenerator(node: self)
    }
}

/**
* HTMLNodeGenerator
*/
public class HTMLNodeGenerator : GeneratorType {
    private var node : HTMLNode?
    
    public init(node: HTMLNode?) {
        self.node = node
    }
    
    public func next() -> HTMLNode? {
        var temp = node
        node = node?.next
        return temp
    }
}

private struct CSS {
    private static func toXPath(selector: String) -> String? {
        func firstMatch(pattern: String)(str: String) -> NSTextCheckingResult? {
            if let regex = NSRegularExpression(pattern: pattern, options: .AnchorsMatchLines, error: nil) {
                if let result = regex.firstMatchInString(str, options: .ReportProgress, range: NSRange(location: 0, length: count(str.utf8))) {
                    return result
                }
            }
            return nil
        }
        
        let matchBlank            = firstMatch("^\\s*|\\s$")
        let matchElement          = firstMatch("^([#.]?)([a-z0-9\\*_-]*)((\\|)([a-z0-9\\*_-]*))?")
        let matchAttr1            = firstMatch("^\\[([^\\]]*)\\]")
        let matchAttr2            = firstMatch("^\\[\\s*([^~\\|\\^\\$\\*=\\s]+)\\s*([~\\|\\^\\$\\*]?=)\\s*[\"\']([^\"]*)[\"\']\\s*\\]")
        let matchAttrN            = firstMatch("^:not\\((.*?)\\)")
        let matchPseudo           = firstMatch("^:([()a-z0-9_+-]+)")
        let matchCombinator       = firstMatch("^(\\s*[>+~\\s])")
        let matchComma            = firstMatch("^\\s*,\\s*")
        let matchSubNthChild      = firstMatch("^(nth-child|nth-last-child)\\((\\d+)\\)")
        let matchSubNthChildN     = firstMatch("^(nth-child|nth-last-child)\\((-?\\d+)n(\\+\\d+)?\\)")
        let matchSubNthOfType     = firstMatch("nth-of-type\\((\\d+)\\)")
        let matchSubContains      = firstMatch("contains\\((.*?)\\)")
        let matchSubBlank         = firstMatch("^\\s*$")
        
        func nth(prefix: String, a: Int, b: Int) -> String {
            let sibling = "\(prefix)-sibling::*"
            if a == 0 {
                return "[count(\(sibling)) = \(b-1)]"
            } else if a > 0 {
                if b != 0 {
                    return "[((count(\(sibling)) + 1) >= \(b)) and  ((((count(\(sibling)) + 1)-\(b)) mod \(a)) = 0)]"
                }
                return "((count(\(sibling)) + 1) mod \(a)) = 0]"
            }
            let a = abs(a)
            return "[(count(\(sibling) + 1) <= \(b)" + ((a != 0) ? " and ((((count(\(sibling)) + 1)-\(b)) mod \(a) = 0)" : "") + "]"
        }
        
        // a(n) + b | a(n) - b
        func nth_child(a: Int, b: Int) -> String {
            return nth("preceding", a, b)
        }
        
        func nth_last_child(a: Int, b: Int) -> String {
            return nth("following", a, b)
        }

        var xpath = "//*"
        var str = selector
        
        while count(str.utf8) > 0 {
            if let result = matchBlank(str: str) {
                str = (str as NSString).substringFromIndex(result.range.length)
            }
            
            if let result = matchElement(str: str) {
                let attr = (str as NSString).substringWithRange(result.rangeAtIndex(1))
                let text = (str as NSString).substringWithRange(result.rangeAtIndex(2))
                if attr.hasPrefix("#") {
                    xpath += "[@id=\(text)]"
                } else if attr.hasPrefix(".") {
                    xpath += "[contains(concat(' ', normalize-space(@class), ' '), ' \(text) ')]"
                } else {
                    if xpath.hasSuffix("*") && text != "" {
                        xpath = xpath.substringToIndex(xpath.endIndex.predecessor()) + text
                    } else {
                        xpath +=  "*"
                    }
                }
                str = (str as NSString).substringFromIndex(result.range.length)
            }
            
            if let result = matchAttr2(str: str) {
                let attr = (str as NSString).substringWithRange(result.rangeAtIndex(1))
                let expr = (str as NSString).substringWithRange(result.rangeAtIndex(2))
                let text = (str as NSString).substringWithRange(result.rangeAtIndex(3))
                switch expr {
                case "!=":
                    xpath += "[@\(attr) != \(text)]"
                case "~=":
                    xpath += "[contains(concat(' ', @\(attr), ' '), concat(' ', '\(text)', ' '))]"
                case "|=":
                    xpath += "[@\(attr) = '\(text)' or starts-with(@\(attr), concat('\(text)', '-'))]"
                case "^=":
                    xpath += "[starts-with(@\(attr), '\(text)')]"
                case "$=":
                    xpath += "[substring(@\(attr), string-length(@\(attr)) - string-length('\(text)') + 1, string-length('\(text)')) = '\(text)']"
                case "*=":
                    xpath += "[contains(@\(attr), '\(text)')]"
                default:
                    xpath += "[@\(attr) = '\(text)']"
                }
                str = (str as NSString).substringFromIndex(result.range.length)
            } else if let result = matchAttr1(str: str) {
                let atr = (str as NSString).substringWithRange(result.rangeAtIndex(1))
                xpath += "[@\(atr)]"
                str = (str as NSString).substringFromIndex(result.range.length)
            } else if str.hasPrefix("[") {
                // bad syntax attribute
                return nil
            }
            
            if let result = matchAttrN(str: str) {
                str = (str as NSString).substringFromIndex(result.range.length)
            }
            
            // pseudoclasses / pseudoelements
            while let result = matchPseudo(str: str) {
                let one = (str as NSString).substringWithRange(result.rangeAtIndex(1))
                switch one {
                case "first-child":
                    xpath += "[count(preceding-sibling::*) = 0]"
                case "last-child":
                    xpath += "[count(following-sibling::*) = 0]"
                case "only-child":
                    xpath += "[count(preceding-sibling::*) = 0 and count(following-sibling::*) = 0]"
                case "first-of-type":
                    xpath += "[position() = 1]"
                case "last-of-type":
                    xpath += "[position() = last()]"
                case "only-of-type":
                    xpath += "[last() = 1]"
                case "empty":
                    xpath += "[not(node())]"
                case "root":
                    xpath += "[not(parent::*)]"
                case "nth-child(odd)":
                    xpath += "[((count(preceding-sibling::*) + 1) >= 1) and ((((count(preceding-sibling::*) + 1)-1) mod 2) = 0)]"
                case "nth-child(even)":
                    xpath += "[((count(preceding-sibling::*) + 1) mod 2) = 0]"
                case "last-child":
                    xpath += "[count(following-sibling::*) = 0]"
                default:
                    if let sub = matchSubNthChild(str: one) {
                        let nth = (one as NSString).substringWithRange(sub.rangeAtIndex(1))
                        let b   = (one as NSString).substringWithRange(sub.rangeAtIndex(2))
                        let arg = (0, b.toInt()!)
                        xpath += (nth == "nth-child") ? nth_child(arg) : nth_last_child(arg)
                    } else if let sub = matchSubNthChildN(str: one) {
                        let nth = (one as NSString).substringWithRange(sub.rangeAtIndex(1))
                        let a   = (one as NSString).substringWithRange(sub.rangeAtIndex(2))
                        let b   = (sub.rangeAtIndex(3).length > 0) ? (one as NSString).substringWithRange(sub.rangeAtIndex(3)) : "0"
                        let arg = (a.toInt()!, b.toInt()!)
                        xpath += (nth == "nth-child") ? nth_child(arg) : nth_last_child(arg)
                    } else if let sub = matchSubNthOfType(str: one) {
                        let a   = (one as NSString).substringWithRange(sub.rangeAtIndex(1))
                        xpath += "[position() = \(a)]"
                    } else if let sub = matchSubContains(str: one) {
                        let text = (one as NSString).substringWithRange(sub.rangeAtIndex(1))
                        xpath += "[contains(., '\(text)']"
                    } else {
                        return nil
                    }
                }
                str = (str as NSString).substringFromIndex(result.range.length)
            }
            
            // matchCombinator
            if let result = matchCombinator(str: str) {
                let one = (str as NSString).substringWithRange(result.rangeAtIndex(1))
                switch one {
                case ">":
                    xpath += "/"
                case "+":
                    xpath += "/following-sibling::*[1]/self::"
                case "~":
                    xpath += "/following-sibling::"
                default:
                    if let sub = matchSubBlank(str: one) {
                        xpath += "//"
                    }
                    break
                }
                str = (str as NSString).substringFromIndex(result.range.length)
            }
            
            
            // comma
            if let result = matchComma(str: str) {
                xpath += " | //"
                str = (str as NSString).substringFromIndex(result.range.length)
            }
        }
        return xpath
    }
}
