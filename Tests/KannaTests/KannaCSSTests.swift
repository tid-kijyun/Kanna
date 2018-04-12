/**@file KannaCSSTests.swift

 Kanna

 @Copyright (c) 2015 Atsushi Kiwaki (@_tid_)

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
import XCTest
import Foundation
import CoreFoundation
@testable import Kanna

class KannaCSSTests: XCTestCase {
    let css2xpath: [(css: String, xpath: String)] = [
        ("*, div", "//* | //div"),
        (".myclass", "//*[contains(concat(' ', normalize-space(@class), ' '), ' myclass ')]"),
        ("#myid", "//*[@id = 'myid']"),
        ("div.myclass#myid", "//div[contains(concat(' ', normalize-space(@class), ' '), ' myclass ') and @id = 'myid']"),
        (".myclass.myclass2", "//*[contains(concat(' ', normalize-space(@class), ' '), ' myclass ') and contains(concat(' ', normalize-space(@class), ' '), ' myclass2 ')]"),
        ("div span", "//div//span"),
        ("ul.info li.favo", "//ul[contains(concat(' ', normalize-space(@class), ' '), ' info ')]//li[contains(concat(' ', normalize-space(@class), ' '), ' favo ')]"),
        ("div > span", "//div/span"),
        ("div + span", "//div/following-sibling::*[1]/self::span"),
        ("div ~ span", "//div/following-sibling::span"),
        ("div[attr]", "//div[@attr]"),
        ("div[attr='val']", "//div[@attr = 'val']"),
        ("div[attr=\"val\"]", "//div[@attr = 'val']"),
        ("div[attr~='val']", "//div[contains(concat(' ', @attr, ' '),concat(' ', 'val', ' '))]"),
        ("div[attr~=\"val\"]", "//div[contains(concat(' ', @attr, ' '),concat(' ', 'val', ' '))]"),
        ("div[attr|='val']", "//div[@attr = 'val' or starts-with(@attr,concat('val', '-'))]"),
        ("div[attr|=\"val\"]", "//div[@attr = 'val' or starts-with(@attr,concat('val', '-'))]"),
        ("div[attr*='val']", "//div[contains(@attr, 'val')]"),
        ("div[attr*=\"val\"]", "//div[contains(@attr, 'val')]"),
        ("div[attr^='val']", "//div[starts-with(@attr, 'val')]"),
        ("div[attr^=\"val\"]", "//div[starts-with(@attr, 'val')]"),
        ("div[attr$='val']", "//div[substring(@attr, string-length(@attr) - string-length('val') + 1, string-length('val')) = 'val']"),
        ("div[attr$=\"val\"]", "//div[substring(@attr, string-length(@attr) - string-length('val') + 1, string-length('val')) = 'val']"),
        ("img[src=jpg]", "//img[@src = 'jpg']"),
        ("img[src~=jpg]", "//img[contains(concat(' ', @src, ' '),concat(' ', 'jpg', ' '))]"),
        ("img[src|=jpg]", "//img[@src = 'jpg' or starts-with(@src,concat('jpg', '-'))]"),
        ("img[src*=jpg]", "//img[contains(@src, 'jpg')]"),
        ("img[src^=jpg]", "//img[starts-with(@src, 'jpg')]"),
        ("img[src$=jpg]", "//img[substring(@src, string-length(@src) - string-length('jpg') + 1, string-length('jpg')) = 'jpg']"),
        ("div:first-child", "//div[count(preceding-sibling::*) = 0]"),
        ("div:last-child", "//div[count(following-sibling::*) = 0]"),
        ("div:only-child", "//div[count(preceding-sibling::*) = 0 and count(following-sibling::*) = 0]"),
        ("div:first-of-type", "//div[position() = 1]"),
        ("div:last-of-type", "//div[position() = last()]"),
        ("div:only-of-type", "//div[last() = 1]"),
        ("div:empty", "//div[not(node())]"),
        ("div:nth-child(0)", "//div[count(preceding-sibling::*) = -1]"),
        ("div:nth-child(3)", "//div[count(preceding-sibling::*) = 2]"),
        ("div:nth-child(odd)", "//div[((count(preceding-sibling::*) + 1) >= 1) and ((((count(preceding-sibling::*) + 1)-1) mod 2) = 0)]"),
        ("div:nth-child(even)", "//div[((count(preceding-sibling::*) + 1) mod 2) = 0]"),
        ("div:nth-child(3n)", "//div[((count(preceding-sibling::*) + 1) mod 3) = 0]"),
        ("div:nth-last-child(2)", "//div[count(following-sibling::*) = 1]"),
        ("div:nth-of-type(odd)", "//div[(position() >= 1) and (((position()-1) mod 2) = 0)]"),
        ("*:root", "//*[not(parent::*)]"),
        ("div:contains('foo')", "//div[contains(., 'foo')]"),
        ("div:contains(\"foo\")", "//div[contains(., 'foo')]"),
        ("div:not([type='text'])", "//div[not(@type = 'text')]"),
        ("div:not([type=\"text\"])", "//div[not(@type = 'text')]"),
        ("*:not(div)", "//*[not(self::div)]"),
        ("#content > p:not(.article-meta)", "//*[@id = 'content']/p[not(contains(concat(' ', normalize-space(@class), ' '), ' article-meta '))]"),
        ("div:not(:nth-child(-n+2))", "//div[not((count(preceding-sibling::*) + 1) <= 2)]"),
        ("*:not(:not(div))", "//*[not(not(self::div))]"),
        ("o|Author", "//o:Author"),
        // escaping
        ("o|A\\.uthor", "//o:A.uthor"),
        ("E\\!L\\\"E\\#M\\$E\\%N\\&T_E\\\'L\\(E\\)\\*M\\+E\\.N\\:T_E\\;L\\<E\\=M\\>E\\?N\\@T_\\[E\\\\L\\]E\\^M\\`E\\{N\\|T_E\\}L\\~E#my\\.id", "//E!L\"E#M$E%N&T_E\'L(E)*M+E.N:T_E;L<E=M>E?N@T_[E\\L]E^M`E{N|T_E}L~E[@id = 'my.id']")
    ]

    let invalidCSS = [
        "h2..foo",
        "h1, h2..foo, h3",
    ]

    func testCSStoXPath() {
        for testCase in css2xpath {
            do {
                let xpath = try CSS.toXPath(testCase.css)
                XCTAssert(xpath == testCase.xpath, "Create XPath = [\(xpath)] != [\(testCase.xpath)]")
            } catch {
                XCTAssert(false, error.localizedDescription)
            }
        }
    }

    func testInvalidCSStoXPath() {
        for css in invalidCSS {
            XCTAssertThrowsError(try CSS.toXPath(css))
        }
    }
}

extension KannaCSSTests {
    static var allTests: [(String, (KannaCSSTests) -> () throws -> Void)] {
        return [
            ("testCSStoXPath", testCSStoXPath),
        ]
    }
}
