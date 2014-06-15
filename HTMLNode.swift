/**@file
 * @brief Swift-HTML-Parser
 * @author _tid_
 */

/**
 * HTMLNode
 */
class HTMLNode {
    enum HTMLNodeType : String {
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
    
    var doc       : htmlDocPtr
    var node      : xmlNode?
    let nodeType  : HTMLNodeType = HTMLNodeType.HTMLUnkownNode
    
    /**
     * 親ノード
     */
    var parent    : HTMLNode? {
        if let p = self.node?.parent {
            return HTMLNode(doc: self.doc, node: p)
        }
        return nil
    }

    /**
    * 次ノード
    */
    var next : HTMLNode? {
        if let n : UnsafePointer<xmlNode> = node?.next {
            if n {
                return HTMLNode(doc: doc, node: n)
            }
        }
        return nil
    }

    /**
     * 子ノード
     */
    var child     : HTMLNode? {
        if let c = node?.children {
            if c {
                return HTMLNode(doc: doc, node: c)
            }
        }
        return nil
    }

    /**
     * クラス名
     */
    var className : String {
        return getAttributeNamed("class")
    }

    /**
    * タグ名
    */
    var tagName : String {
        if node {
            return ConvXmlCharToString(self.node!.name)
        }
        return ""
    }
    
    /**
     * コンテンツ
     */
    var contents : String {
        if node {
            var n = self.node!.children
            if n {
                return ConvXmlCharToString(n.memory.content)
            }
        }
        return ""
    }

    /**
     * Initializer
     * @param[in] doc xmlDoc
     */
    init(doc: htmlDocPtr = nil) {
        self.doc  = doc
        var node = xmlDocGetRootElement(doc)
        if node {
            self.node = node.memory
        }
    }
    
    init(doc: htmlDocPtr, node: UnsafePointer<xmlNode>) {
        self.doc  = doc
        self.node = node.memory

        if let type = HTMLNodeType.fromRaw(tagName) {
            nodeType = type
        }
    }

    /**
     * 属性名を取得する
     * @param[in] name 属性
     * @return 属性名
     */
    func getAttributeNamed(name: String) -> String {
        for var attr : xmlAttrPtr = node!.properties; attr; attr = attr.memory.next {
            if attr {
                var mem = attr.memory

                if name == ConvXmlCharToString(mem.name) {
                    return ConvXmlCharToString(mem.children.memory.content)
                }
            }
        }
        
        return ""
    }
    
    /**
     * タグ名に一致する全ての子ノードを探す
     * @param[in] tagName タグ名
     * @return 子ノードの配列
     */
    func findChildTags(tagName: String) -> HTMLNode[] {
        var nodes : HTMLNode[] = []
        
        return findChildTags(tagName, node: self.child, retAry: &nodes)
    }
    
    func findChildTags(tagName: String, node: HTMLNode?, inout retAry: HTMLNode[] ) -> HTMLNode[] {
        if node {
            for n in node! {
                if n.tagName == tagName {
                    retAry.append(n)
                }
            
                findChildTags(tagName, node: n.child, retAry: &retAry)
            }
        }
        return retAry
    }
    
    /**
     * タグ名で子ノードを探す
     * @param[in] tagName タグ名
     * @return 子ノード。見つからなければnil
     */
    func findChildTag(tagName: String) -> HTMLNode? {
        return findChildTag(tagName, node: self)
    }

    func findChildTag(tagName: String, node: HTMLNode?) -> HTMLNode? {
        if node == nil {
            return nil
        }
        
        for curNode in node! {
            if tagName == curNode.tagName {
                return curNode
            }
            
            if let c = curNode.child {
                if let n = findChildTag(tagName, node: c) {
                    return n
                }
            }
        }

        return nil
    }
}

extension HTMLNode : Sequence {
    func generate() -> HTMLNodeGenerator {
        return HTMLNodeGenerator(node: self)
    }
}

/**
* HTMLNodeGenerator
*/
class HTMLNodeGenerator : Generator {
    var node : HTMLNode?
    
    init(node: HTMLNode?) {
        self.node = node
    }
    
    func next() -> HTMLNode? {
        var temp = node?
        node = node?.next
        return temp
    }
}

