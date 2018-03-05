/**@file KannaXMLTests.swift

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

class KannaXMLTests: XCTestCase {
    func testXml() {
        let filename = "test_XML_ExcelWorkbook"
        guard let path = Bundle(for:KannaXMLTests.self).path(forResource: filename, ofType:"xml") else {
            return
        }
        if let xml = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let doc = try? XML(xml: xml, encoding: .utf8) {
            let namespaces = [
                "o":  "urn:schemas-microsoft-com:office:office",
                "ss": "urn:schemas-microsoft-com:office:spreadsheet"
            ]

            if let author = doc.at_xpath("//o:Author", namespaces: namespaces) {
                XCTAssert(author.text == "_tid_")
            } else {
                XCTAssert(false, "Author not found.")
            }

            if let createDate = doc.at_xpath("//o:Created", namespaces: namespaces) {
                XCTAssert(createDate.text == "2015-07-26T06:00:00Z")
            } else {
                XCTAssert(false, "Create date not found.")
            }


            for row in doc.xpath("//ss:Row", namespaces: namespaces) {
                for cell in row.xpath("//ss:Data", namespaces: namespaces) {
                    print(cell.text!)
                }
            }
        } else {
            XCTAssert(false, "File not found. name: (\(filename))")
        }
    }

    func testXmlThrows() {
        XCTAssertThrowsError(try XML(xml: "", encoding: .utf8))
    }
}

extension KannaXMLTests {
    static var allTests: [(String, (KannaXMLTests) -> () throws -> Void)] {
        return [
            //("testXml", testXml),
            ("testXmlThrows", testXmlThrows),
        ]
    }
}
