/**@file KannaHTMLTests.swift

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

class KannaHTMLTests: XCTestCase {
    func testHTML4() {
        // This is an example of a functional test case.
        let filename = "test_HTML4"
        guard let path = Bundle(for:KannaHTMLTests.self).path(forResource: filename, ofType:"html") else {
            return
        }
        
        do {
            let html = try String(contentsOfFile: path, encoding: .utf8)
            guard let doc = try? HTML(html: html, encoding: .utf8) else {
                return
            }
            // Check title
            XCTAssert(doc.title == "Test HTML4")
            XCTAssert(doc.head != nil)
            XCTAssert(doc.body != nil)
            XCTAssert(doc.toHTML!.hasPrefix("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n<html lang=\"en\">"))

            XCTAssert(doc.xpath("//link").count == 2)

            for link in doc.xpath("//link") {
                XCTAssert(link["href"] != nil)
            }
            
            let repoName = ["Kanna", "Swift-HTML-Parser"]
            for (index, repo) in doc.xpath("//span[@class='repo']").enumerated() {
                XCTAssert(repo["title"] == repoName[index])
                XCTAssert(repo.text == repoName[index])
            }
            
            if let snTable = doc.at_css("table[id='sequence number']") {
                let alphabet = ["a", "b", "c"]
                for (indexTr, tr) in snTable.css("tr").enumerated() {
                    for (indexTd, td) in tr.css("td").enumerated() {
                        XCTAssert(td.text == "\(alphabet[indexTd])\(indexTr)")
                    }
                }
            }
            
            if let starTable = doc.at_css("table[id='star table']"),
                   let allStarStr = starTable.at_css("tfoot > tr > td:nth-child(2)")?.text,
                   let allStar = Int(allStarStr) {
                    var count = 0
                    for starNode in starTable.css("tbody > tr > td:nth-child(2)") {
                        if let starStr = starNode.text,
                               let star    = Int(starStr) {
                            count += star
                        }
                    }
                    
                    XCTAssert(count == allStar)
            } else {
                XCTAssert(false, "Star not found.")
            }

            if var link = doc.at_xpath("//link") {
                let attr = "src-data"
                let testData = "TestData"
                link[attr] = testData
                XCTAssert(link[attr] == testData)
            }

            XCTAssert(doc.xpath("true()").boolValue == true)
            XCTAssert(doc.xpath("number(123)").numberValue == 123)
            XCTAssert(doc.xpath("concat((//a/@href)[1], (//a/@href)[2])").stringValue == "/tid-kijyun/Kanna/tid-kijyun/Swift-HTML-Parser")
        } catch {
            XCTAssert(false, "File not found. name: (\(filename)), error: \(error)")
        }
    }
    
    func testInnerHTML() {
        let filename = "test_HTML4"
        guard let path = Bundle(for:KannaHTMLTests.self).path(forResource: filename, ofType:"html") else {
            return
        }
        
        do {
            let html = try String(contentsOfFile: path, encoding: .utf8)
            guard let doc = try? HTML(html: html, encoding: .utf8) else {
                return
            }
            
            XCTAssert(doc.at_css("div#inner")!.innerHTML == "\n        abc<div>def</div>hij<span>klmn</span>opq\n    ")
            XCTAssert(doc.at_css("#asd")!.innerHTML == "asd")
        } catch {
            XCTAssert(false, "File not found. name: (\(filename)), error: \(error)")
        }
    }

    func testNSURL() {
        // Due to bugs, this test will fail on older versions of Swift for Linux.
        // https://github.com/apple/swift-corelibs-foundation/pull/1499
        #if !os(Linux) || swift(>=4.2)
        guard let url = URL(string: "https://en.wikipedia.org/wiki/Cat"),
              let _ = try? HTML(url: url, encoding: .utf8) else {
            XCTAssert(false)
            return
        }
        #endif
    }

    func testNextPreviousSibling() {
        let html = "<body><div>first</div><div>second</div><div>third</div></body>"
        guard let doc = try? HTML(html: html, encoding: .utf8),
            let node = doc.css("div:nth-child(2)").first else {
            XCTFail()
            return
        }

        guard let next = node.nextSibling else {
            XCTFail("Next sibling not found")
            return
        }
        XCTAssert(next.text == "third")

        guard let previous = node.previousSibling else {
            XCTFail("Previous sibling not found")
            return
        }
        XCTAssert(previous.text == "first")
    }

    func testEscapeId() {
        let html = "<body><div id='my.id'>target</div><div>second</div><div>third</div></body>"
        guard let doc = try? HTML(html: html, encoding: .utf8),
            let node = doc.css("div[id='my\\.id']").first else {
                XCTFail()
                return
        }

        XCTAssert(node.text == "target")
    }

    func testOutOfDocument() {
        let filename = "test_HTML4"
        guard let path = Bundle(for:KannaHTMLTests.self).path(forResource: filename, ofType:"html") else {
            return
        }

        var elements: [Kanna.XMLElement] = []

        do {
            let html = try String(contentsOfFile: path, encoding: .utf8)
            if let doc = try? HTML(html: html, encoding: .utf8) {
                for node in doc.css("div#inner > div") {
                    elements.append(node)
                }
            }
        } catch {
            XCTAssert(false, "File not found. name: (\(filename)), error: \(error)")
        }

        for element in elements {
            XCTAssert(element.text! == "def")
        }
    }

    func testNoTagElement() {
        let input = """
        <div>
        <style>@media all and (max-width:720px){.mw-parser-output .tmulti>.thumbinner{width:100%!important;max-width:none!important}.mw-parser-output .tmulti .tsingle{float:none!important;max-width:none!important;width:100%!important;text-align:center}}</style>
        </div>
        """

        do {
            let doc = try HTML(html: input, encoding: .utf8)
            XCTAssertNil(doc.body?.at_xpath("//style/child::text()")?.tagName)
        } catch {
            XCTFail()
        }
    }
}

extension KannaHTMLTests {
    static var allTests: [(String, (KannaHTMLTests) -> () throws -> Void)] {
        return [
            //("testHTML4", testHTML4),
            //("testInnerHTML", testInnerHTML),
            ("testNSURL", testNSURL),
        ]
    }
}
