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
            var n = self.node!.children
            if n != nil {
                return ConvXmlCharToString(n.memory.content)
            }
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
                return ConvXmlCharToString(mem.children.memory.content)
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
