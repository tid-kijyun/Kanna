/**@file KannaXMLModifyingTests.swift

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

class KannaXMLModifyingTests: XCTestCase {
    func testXML_MovingNode() {
        let xml = "<?xml version=\"1.0\"?><all_item><item><title>item0</title></item><item><title>item1</title></item></all_item>"
        let modifyPrevXML = "<all_item><item><title>item1</title></item><item><title>item0</title></item></all_item>"
        let modifyNextXML = "<all_item><item><title>item1</title></item><item><title>item0</title></item></all_item>"

        do {
            guard let doc = try? XML(xml: xml, encoding: .utf8) else {
                return
            }
            let item0 = doc.css("item")[0]
            let item1 = doc.css("item")[1]
            item0.addPrevSibling(item1)
            XCTAssert(doc.at_css("all_item")!.toXML == modifyPrevXML)
        }

        do {
            guard let doc = try? XML(xml: xml, encoding: .utf8) else {
                return
            }
            let item0 = doc.css("item")[0]
            let item1 = doc.css("item")[1]
            item1.addNextSibling(item0)
            XCTAssert(doc.at_css("all_item")!.toXML == modifyNextXML)
        }
    }
}

extension KannaXMLModifyingTests {
    static var allTests: [(String, (KannaXMLModifyingTests) -> () throws -> Void)] {
        return [
            ("testXML_MovingNode", testXML_MovingNode),
        ]
    }
}
