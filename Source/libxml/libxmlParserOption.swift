/**@file libxmlParserOption.swift

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

/*
Libxml2HTMLParserOptions
*/
public struct Libxml2HTMLParserOptions : OptionSetType {
    public typealias RawValue = UInt
    private var value: UInt = 0
    init(_ value: UInt) { self.value = value }
    private init(_ opt: htmlParserOption) { self.value = UInt(opt.rawValue) }
    public init(rawValue value: UInt) { self.value = value }
    public init(nilLiteral: ()) { self.value = 0 }
    public static var allZeros: Libxml2HTMLParserOptions { return self.init(0) }
    static func fromMask(raw: UInt) -> Libxml2HTMLParserOptions { return self.init(raw) }
    public var rawValue: UInt { return self.value }
    
    static var STRICT:     Libxml2HTMLParserOptions { return Libxml2HTMLParserOptions(0) }
    static var RECOVER:    Libxml2HTMLParserOptions { return Libxml2HTMLParserOptions(HTML_PARSE_RECOVER) }
    static var NODEFDTD:   Libxml2HTMLParserOptions { return Libxml2HTMLParserOptions(HTML_PARSE_NODEFDTD) }
    static var NOERROR:    Libxml2HTMLParserOptions { return Libxml2HTMLParserOptions(HTML_PARSE_NOERROR) }
    static var NOWARNING:  Libxml2HTMLParserOptions { return Libxml2HTMLParserOptions(HTML_PARSE_NOWARNING) }
    static var PEDANTIC:   Libxml2HTMLParserOptions { return Libxml2HTMLParserOptions(HTML_PARSE_PEDANTIC) }
    static var NOBLANKS:   Libxml2HTMLParserOptions { return Libxml2HTMLParserOptions(HTML_PARSE_NOBLANKS) }
    static var NONET:      Libxml2HTMLParserOptions { return Libxml2HTMLParserOptions(HTML_PARSE_NONET) }
    static var NOIMPLIED:  Libxml2HTMLParserOptions { return Libxml2HTMLParserOptions(HTML_PARSE_NOIMPLIED) }
    static var COMPACT:    Libxml2HTMLParserOptions { return Libxml2HTMLParserOptions(HTML_PARSE_COMPACT) }
    static var IGNORE_ENC: Libxml2HTMLParserOptions { return Libxml2HTMLParserOptions(HTML_PARSE_IGNORE_ENC) }
}

/*
Libxml2XMLParserOptions
*/
public struct Libxml2XMLParserOptions: OptionSetType {
    public typealias RawValue = UInt
    private var value: UInt = 0
    init(_ value: UInt) { self.value = value }
    private init(_ opt: xmlParserOption) { self.value = UInt(opt.rawValue) }
    public init(rawValue value: UInt) { self.value = value }
    public init(nilLiteral: ()) { self.value = 0 }
    public static var allZeros: Libxml2XMLParserOptions { return self.init(0) }
    static func fromMask(raw: UInt) -> Libxml2XMLParserOptions { return self.init(raw) }
    public var rawValue: UInt { return self.value }
    
    static var STRICT:     Libxml2XMLParserOptions { return Libxml2XMLParserOptions(0) }
    static var RECOVER:    Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_RECOVER) }
    static var NOENT:      Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_NOENT) }
    static var DTDLOAD:    Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_DTDLOAD) }
    static var DTDATTR:    Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_DTDATTR) }
    static var DTDVALID:   Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_DTDVALID) }
    static var NOERROR:    Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_NOERROR) }
    static var NOWARNING:  Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_NOWARNING) }
    static var PEDANTIC:   Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_PEDANTIC) }
    static var NOBLANKS:   Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_NOBLANKS) }
    static var SAX1:       Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_SAX1) }
    static var XINCLUDE:   Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_XINCLUDE) }
    static var NONET:      Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_NONET) }
    static var NODICT:     Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_NODICT) }
    static var NSCLEAN:    Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_NSCLEAN) }
    static var NOCDATA:    Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_NOCDATA) }
    static var NOXINCNODE: Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_NOXINCNODE) }
    static var COMPACT:    Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_COMPACT) }
    static var OLD10:      Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_OLD10) }
    static var NOBASEFIX:  Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_NOBASEFIX) }
    static var HUGE:       Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_HUGE) }
    static var OLDSAX:     Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_OLDSAX) }
    static var IGNORE_ENC: Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_IGNORE_ENC) }
    static var BIG_LINES:  Libxml2XMLParserOptions { return Libxml2XMLParserOptions(XML_PARSE_BIG_LINES) }
}
