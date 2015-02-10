/**@file
* @brief Swift-HTML-Parser
* @author _tid_
*/
import Foundation

let DUMP_BUFFER_SIZE : UInt = 4000

func ConvXmlCharToString(str: UnsafePointer<xmlChar>) -> String! {
    if str != nil {
        return String.fromCString(UnsafeMutablePointer<CChar>(str))
    }
    return ""
}

func rawContentsOfNode(node : xmlNode, pointer: xmlNodePtr) -> String! {
    var result : String?
    var xmlBuffer = xmlBufferCreateSize(DUMP_BUFFER_SIZE)
    var outputBuffer : xmlOutputBufferPtr = xmlOutputBufferCreateBuffer(xmlBuffer, nil)
    
    let document = node.doc
    
    let xmlCharContent = document.memory.encoding
    let contentAddress = unsafeBitCast(xmlCharContent, UnsafePointer<xmlChar>.self)
    let constChar = UnsafePointer<Int8>(contentAddress)
    
    htmlNodeDumpOutput(outputBuffer, document, pointer, constChar)
    xmlOutputBufferFlush(outputBuffer)
    
    if xmlBuffer.memory.content != nil {
        result = ConvXmlCharToString(xmlBuffer.memory.content)
    }
    
    xmlOutputBufferClose(outputBuffer)
    xmlBufferFree(xmlBuffer)
    
    return result
}

/**
* HTMLParser
*/
public class HTMLParser {
    private var _doc     : htmlDocPtr = nil
    private var rootNode : HTMLNode?
    public var htmlString : String = ""
    
    /**
    * HTML tag
    */
    public var html : HTMLNode? {
        return rootNode?.findChildTag("html")
    }
    
    /**
    * HEAD tag
    */
    public var head : HTMLNode? {
        return rootNode?.findChildTag("head")
    }
    
    /**
    * BODY tag
    */
    public var body : HTMLNode? {
        return rootNode?.findChildTag("body")
    }
    
    /**
    * @param[in] html  HTML文字列
    * @param[in] error エラーがあれば返します
    */
    public init(html: String, inout error: NSError?) {
        if html.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            self.htmlString = html
            var cfenc : CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)
            var cfencstr : CFStringRef   = CFStringConvertEncodingToIANACharSetName(cfenc)
            
            var cur : [CChar]? = html.cStringUsingEncoding(NSUTF8StringEncoding)
            var url : String = ""
            var enc = CFStringGetCStringPtr(cfencstr, 0)
            let optionHtml : CInt = 1
            
            if var ucur = cur {
                _doc = htmlReadDoc(UnsafePointer<CUnsignedChar>(ucur), url, enc, optionHtml)
                rootNode  = HTMLNode(doc: _doc)
            } else {
                error = NSError(domain: "HTMLParserdomain", code: 1, userInfo: nil)
            }
        } else {
            error = NSError(domain: "HTMLParserdomain", code: 1, userInfo: nil)
        }
    }
    
    public init(html: String, encoding : UInt, inout error: NSError?) {
        if html.lengthOfBytesUsingEncoding(encoding) > 0 {
            self.htmlString = html
            var cfenc : CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(encoding)
            var cfencstr : CFStringRef   = CFStringConvertEncodingToIANACharSetName(cfenc)
            
            var cur : [CChar]? = html.cStringUsingEncoding(encoding)
            var url : String = ""
            var enc = CFStringGetCStringPtr(cfencstr, 0)
            let optionHtml : CInt = 1
            
            if var ucur = cur {
                _doc = htmlReadDoc(UnsafePointer<CUnsignedChar>(ucur), url, enc, optionHtml)
                rootNode  = HTMLNode(doc: _doc)
            } else {
                error = NSError(domain: "HTMLParserdomain", code: 1, userInfo: nil)
            }
        } else {
            error = NSError(domain: "HTMLParserdomain", code: 1, userInfo: nil)
        }
    }
    
    deinit {
        xmlFreeDoc(_doc)
    }
}
