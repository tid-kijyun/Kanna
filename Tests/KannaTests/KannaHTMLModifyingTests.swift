/**@file KannaHTMLModifyingTests.swift

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

class KannaHTMLModifyingTests: XCTestCase {
    func testHTML_MovingNode() {
        let html = "<body><div>A love triangle.<h1>Three's Company</h1></div></body>"
        let modifyPrevHTML = "<body>\n<h1>Three's Company</h1>\n<div>A love triangle.</div>\n</body>"
        let modifyNextHTML = "<body>\n<div>A love triangle.</div>\n<h1>Three's Company</h1>\n</body>"

        do {
            guard let doc = try? HTML(html: html, encoding: .utf8),
                let h1 = doc.at_css("h1"),
                let div = doc.at_css("div") else {
                    return
            }
            div.addPrevSibling(h1)
            XCTAssert(doc.body!.toHTML == modifyPrevHTML)
        }

        do {
            guard let doc = try? HTML(html: html, encoding: .utf8),
                let h1 = doc.at_css("h1"),
                let div = doc.at_css("div") else {
                    return
            }
            div.addNextSibling(h1)
            XCTAssert(doc.body!.toHTML == modifyNextHTML)
        }
    }
}

extension KannaHTMLModifyingTests {
    static var allTests: [(String, (KannaHTMLModifyingTests) -> () throws -> Void)] {
        return [
            ("testHTML_MovingNode", testHTML_MovingNode)
        ]
    }
}

