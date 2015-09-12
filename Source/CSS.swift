/**@file CSS.swift

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

/**
CSS
*/
public struct CSS {
    /**
    CSS3 selector to XPath
    
    @param selector CSS3 selector
    
    @return XPath
    */
    public static func toXPath(selector: String) -> String? {
        var xpath = "//"
        var str = selector
        
        while str.utf8.count > 0 {
            var attributes: [String] = []
            var combinator: String = ""
            
            if let result = matchBlank(str: str) {
                str = (str as NSString).substringFromIndex(result.range.length)
            }
            
            // element
            let element = getElement(&str)
            
            // class / id
            while let attr = getClassId(&str) {
                attributes.append(attr)
            }
            
            // attribute
            while let attr = getAttribute(&str) {
                attributes.append(attr)
            }
            
            // matchCombinator
            if let combi = genCombinator(&str) {
                combinator = combi
            }
            
            // generate xpath phrase
            let attr = attributes.reduce("") { $0.isEmpty ? $1 : $0 + " and " + $1 }
            if attr.isEmpty {
                xpath += "\(element)\(combinator)"
            } else {
                xpath += "\(element)[\(attr)]\(combinator)"
            }
        }
        return xpath
    }
}

private func firstMatch(pattern: String)(str: String) -> NSTextCheckingResult? {
    let length = str.utf8.count
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        if let result = regex.firstMatchInString(str, options: .ReportProgress, range: NSRange(location: 0, length: length)) {
            return result
        }
    } catch _ {
        
    }
    return nil
}

private func nth(prefix prefix: String, a: Int, b: Int) -> String {
    let sibling = "\(prefix)-sibling::*"
    if a == 0 {
        return "count(\(sibling)) = \(b-1)"
    } else if a > 0 {
        if b != 0 {
            return "((count(\(sibling)) + 1) >= \(b)) and ((((count(\(sibling)) + 1)-\(b)) mod \(a)) = 0)"
        }
        return "((count(\(sibling)) + 1) mod \(a)) = 0"
    }
    let a = abs(a)
    return "(count(\(sibling)) + 1) <= \(b)" + ((a != 1) ? " and ((((count(\(sibling)) + 1)-\(b)) mod \(a) = 0)" : "")
}

// a(n) + b | a(n) - b
private func nth_child(a a: Int, b: Int) -> String {
    return nth(prefix: "preceding", a: a, b: b)
}

private func nth_last_child(a a: Int, b: Int) -> String {
    return nth(prefix: "following", a: a, b: b)
}

private let matchBlank        = firstMatch("^\\s*|\\s$")
private let matchElement      = firstMatch("^([a-z0-9\\*_-]+)((\\|)([a-z0-9\\*_-]+))?")
private let matchClassId      = firstMatch("^([#.])([a-z0-9\\*_-]+)")
private let matchAttr1        = firstMatch("^\\[([^\\]]*)\\]")
private let matchAttr2        = firstMatch("^\\[\\s*([^~\\|\\^\\$\\*=\\s]+)\\s*([~\\|\\^\\$\\*]?=)\\s*[\"\']([^\"]*)[\"\']\\s*\\]")
private let matchAttrN        = firstMatch("^:not\\((.*?\\)?)\\)")
private let matchPseudo       = firstMatch("^:([\'()a-z0-9_+-]+)")
private let matchCombinator   = firstMatch("^\\s*([\\s>+~,])\\s*")
private let matchSubNthChild  = firstMatch("^(nth-child|nth-last-child)\\(\\s*(odd|even|\\d+)\\s*\\)")
private let matchSubNthChildN = firstMatch("^(nth-child|nth-last-child)\\(\\s*(-?\\d*)n(\\+\\d+)?\\s*\\)")
private let matchSubNthOfType = firstMatch("nth-of-type\\((odd|even|\\d+)\\)")
private let matchSubContains  = firstMatch("contains\\([\"\'](.*?)[\"\']\\)")
private let matchSubBlank     = firstMatch("^\\s*$")

private func substringWithRangeAtIndex(result: NSTextCheckingResult, str: String, at: Int) -> String {
    if result.numberOfRanges > at {
        let range = result.rangeAtIndex(at)
        if range.length > 0 {
            return (str as NSString).substringWithRange(range)
        }
    }
    return ""
}

private func getElement(inout str: String, skip: Bool = true) -> String {
    if let result = matchElement(str: str) {
        let (text, text2) = (substringWithRangeAtIndex(result, str: str, at: 1),
                             substringWithRangeAtIndex(result, str: str, at: 4))
        
        if skip {
            str = str.substringFromIndex(str.startIndex.advancedBy(result.range.length))
        }
        
        // tag with namespace
        if !text.isEmpty && !text2.isEmpty {
            return "\(text):\(text2)"
        }
        
        // tag
        if !text.isEmpty {
            return text
        }
    }
    return "*"
}

private func getClassId(inout str: String, skip: Bool = true) -> String? {
    if let result = matchClassId(str: str) {
        let (attr, text) = (substringWithRangeAtIndex(result, str: str, at: 1),
                            substringWithRangeAtIndex(result, str: str, at: 2))
        if skip {
            str = str.substringFromIndex(str.startIndex.advancedBy(result.range.length))
        }
        
        if attr.hasPrefix("#") {
            return "@id = '\(text)'"
        } else if attr.hasPrefix(".") {
            return "contains(concat(' ', normalize-space(@class), ' '), ' \(text) ')"
        }
    }
    return nil
}

private func getAttribute(inout str: String, skip: Bool = true) -> String? {
    if let result = matchAttr2(str: str) {
        let (attr, expr, text) = (substringWithRangeAtIndex(result, str: str, at: 1),
                                  substringWithRangeAtIndex(result, str: str, at: 2),
                                  substringWithRangeAtIndex(result, str: str, at: 3))
        if skip {
            str = str.substringFromIndex(str.startIndex.advancedBy(result.range.length))
        }
        
        switch expr {
        case "!=":
            return "@\(attr) != \(text)"
        case "~=":
            return "contains(concat(' ', @\(attr), ' '),concat(' ', '\(text)', ' '))"
        case "|=":
            return "@\(attr) = '\(text)' or starts-with(@\(attr),concat('\(text)', '-'))"
        case "^=":
            return "starts-with(@\(attr), '\(text)')"
        case "$=":
            return "substring(@\(attr), string-length(@\(attr)) - string-length('\(text)') + 1, string-length('\(text)')) = '\(text)'"
        case "*=":
            return "contains(@\(attr), '\(text)')"
        default:
            return "@\(attr) = '\(text)'"
        }
    } else if let result = matchAttr1(str: str) {
        let atr = substringWithRangeAtIndex(result, str: str, at: 1)
        if skip {
            str = str.substringFromIndex(str.startIndex.advancedBy(result.range.length))
        }
        
        return "@\(atr)"
    } else if str.hasPrefix("[") {
        // bad syntax attribute
        return nil
    } else if let attr = getAttrNot(&str) {
        return "not(\(attr))"
    } else if let result = matchPseudo(str: str) {
        let one = substringWithRangeAtIndex(result, str: str, at: 1)
        if skip {
            str = str.substringFromIndex(str.startIndex.advancedBy(result.range.length))
        }
        
        switch one {
        case "first-child":
            return "count(preceding-sibling::*) = 0"
        case "last-child":
            return "count(following-sibling::*) = 0"
        case "only-child":
            return "count(preceding-sibling::*) = 0 and count(following-sibling::*) = 0"
        case "first-of-type":
            return "position() = 1"
        case "last-of-type":
            return "position() = last()"
        case "only-of-type":
            return "last() = 1"
        case "empty":
            return "not(node())"
        case "root":
            return "not(parent::*)"
        case "last-child":
            return "count(following-sibling::*) = 0"
        default:
            if let sub = matchSubNthChild(str: one) {
                let (nth, arg1) = (substringWithRangeAtIndex(sub, str: one, at: 1),
                                   substringWithRangeAtIndex(sub, str: one, at: 2))
                
                let nthFunc = (nth == "nth-child") ? nth_child : nth_last_child
                if arg1 == "odd" {
                    return nthFunc(a: 2, b: 1)
                } else if arg1 == "even" {
                    return nthFunc(a: 2, b: 0)
                } else {
                    return nthFunc(a: 0, b: Int(arg1)!)
                }
            } else if let sub = matchSubNthChildN(str: one) {
                let (nth, arg1, arg2) = (substringWithRangeAtIndex(sub, str: one, at: 1),
                                         substringWithRangeAtIndex(sub, str: one, at: 2),
                                         substringWithRangeAtIndex(sub, str: one, at: 3))
                
                let nthFunc = (nth == "nth-child") ? nth_child : nth_last_child
                let a: Int = (arg1 == "-") ? -1 : Int(arg1)!
                let b: Int = (arg2.isEmpty) ? 0 : Int(arg2)!
                return nthFunc(a: a, b: b)
            } else if let sub = matchSubNthOfType(str: one) {
                let arg1   = substringWithRangeAtIndex(sub, str: one, at: 1)
                if arg1 == "odd" {
                    return "(position() >= 1) and (((position()-1) mod 2) = 0)"
                } else if arg1 == "even" {
                    return "(position() mod 2) = 0"
                } else {
                    return "position() = \(arg1)"
                }
            } else if let sub = matchSubContains(str: one) {
                let text = substringWithRangeAtIndex(sub, str: one, at: 1)
                return "contains(., '\(text)')"
            } else {
                return nil
            }
        }
    }
    return nil
}

private func getAttrNot(inout str: String, skip: Bool = true) -> String? {
    if let result = matchAttrN(str: str) {
        var one = substringWithRangeAtIndex(result, str: str, at: 1)
        if skip {
            str = str.substringFromIndex(str.startIndex.advancedBy(result.range.length))
        }
        
        if let attr = getAttribute(&one, skip: false) {
            return attr
        } else if let sub = matchElement(str: one) {
            let elem = (one as NSString).substringWithRange(sub.rangeAtIndex(1))
            return "self::\(elem)"
        }
    }
    return nil
}

private func genCombinator(inout str: String, skip: Bool = true) -> String? {
    if let result = matchCombinator(str: str) {
        let one = substringWithRangeAtIndex(result, str: str, at: 1)
        if skip {
            str = str.substringFromIndex(str.startIndex.advancedBy(result.range.length))
        }
        
        switch one {
        case ">":
            return "/"
        case "+":
            return "/following-sibling::*[1]/self::"
        case "~":
            return "/following-sibling::"
        default:
            if let _ = matchSubBlank(str: one) {
                return "//"
            } else {
                return " | //"
            }
        }
    }
    return nil
}
