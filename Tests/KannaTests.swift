/**@file KannaTests.swift

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
@testable import Kanna

class KannaTests: XCTestCase {
    let css2xpath: [(String, String?)] = [
        ("*, div", "//* | //div"),
        (".myclass", "//*[contains(concat(' ', normalize-space(@class), ' '), ' myclass ')]"),
        ("#myid", "//*[@id = 'myid']"),
        ("div.myclass#myid", "//div[contains(concat(' ', normalize-space(@class), ' '), ' myclass ') and @id = 'myid']"),
        (".myclass.myclass2", "//*[contains(concat(' ', normalize-space(@class), ' '), ' myclass ') and contains(concat(' ', normalize-space(@class), ' '), ' myclass2 ')]"),
        ("div span", "//div//span"),
        ("ul.info li.favo", "//ul[contains(concat(' ', normalize-space(@class), ' '), ' info ')]//li[contains(concat(' ', normalize-space(@class), ' '), ' favo ')]"),
        ("div > span", "//div/span"),
        ("div + span", "//div/following-sibling::*[1]/self::span"),
        ("div[attr]", "//div[@attr]"),
        ("div[attr='val']", "//div[@attr = 'val']"),
        ("div[attr~='val']", "//div[contains(concat(' ', @attr, ' '),concat(' ', 'val', ' '))]"),
        ("div[attr|='val']", "//div[@attr = 'val' or starts-with(@attr,concat('val', '-'))]"),
        ("div[attr*='val']", "//div[contains(@attr, 'val')]"),
        ("div[attr^='val']", "//div[starts-with(@attr, 'val')]"),
        ("div[attr$='val']", "//div[substring(@attr, string-length(@attr) - string-length('val') + 1, string-length('val')) = 'val']"),
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
        ("div:not([type='text'])", "//div[not(@type = 'text')]"),
        ("*:not(div)", "//*[not(self::div)]"),
        ("div:not(:nth-child(-n+2))", "//div[not((count(preceding-sibling::*) + 1) <= 2)]"),
        ("*:not(:not(div))", "//*[not(not(self::div))]"),
        ("o|Author", "//o:Author")
    ]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
    test CSS to XPath
    */
    func testCSStoXPath() {
        css2xpath.map{ (testcase) -> () in
            let xpath = CSS.toXPath(testcase.0)
            XCTAssert(xpath == testcase.1, "Create XPath = [\(xpath)] != [\(testcase.1)]")
        }
    }
    
    /**
    test XML
    */
    func testXml() {
        let filename = "test_XML_ExcelWorkbook"
        if let path = NSBundle(forClass:self.classForCoder).pathForResource(filename, ofType:"xml"),
            xml = NSData(contentsOfFile: path),
            doc = XML(xml: xml, encoding: NSUTF8StringEncoding) {
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
                        print(cell.text)
                    }
                }
        } else {
            XCTAssert(false, "File not found. name: (\(filename))")
        }
    }
    
    /**
    test HTML4
    */
    func testHTML4() {
        // This is an example of a functional test case.
        let filename = "test_HTML4"
        guard let path = NSBundle(forClass:self.classForCoder).pathForResource(filename, ofType:"html") else {
            return
        }
        
        do {
            let html = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            guard let doc = HTML(html: html, encoding: NSUTF8StringEncoding) else {
                return
            }
            // Check title
            XCTAssert(doc.title == "Test HTML4")
            XCTAssert(doc.head != nil)
            XCTAssert(doc.body != nil)
            XCTAssert(doc.toHTML == html)
            
            for link in doc.xpath("//link") {
                XCTAssert(link["href"] != nil)
            }
            
            let repoName = ["Kanna", "Swift-HTML-Parser"]
            for (index, repo) in doc.xpath("//span[@class='repo']").enumerate() {
                XCTAssert(repo["title"] == repoName[index])
                XCTAssert(repo.text == repoName[index])
            }
            
            if let snTable = doc.at_css("table[id='sequence number']") {
                let alphabet = ["a", "b", "c"]
                for (indexTr, tr) in snTable.css("tr").enumerate() {
                    for (indexTd, td) in tr.css("td").enumerate() {
                        XCTAssert(td.text == "\(alphabet[indexTd])\(indexTr)")
                    }
                }
            }
            
            if let starTable = doc.at_css("table[id='star table']"),
                   allStarStr = starTable.at_css("tfoot > tr > td:nth-child(2)")?.text,
                   allStar = Int(allStarStr) {
                    var count = 0
                    for starNode in starTable.css("tbody > tr > td:nth-child(2)") {
                        if let starStr = starNode.text,
                               star    = Int(starStr) {
                            count += star
                        }
                    }
                    
                    XCTAssert(count == allStar)
            } else {
                XCTAssert(false, "Star not found.")
            }
        } catch {
            XCTAssert(false, "File not found. name: (\(filename)), error: \(error)")
        }
    }
    
    func testInnerHTML() {
        let filename = "test_HTML4"
        guard let path = NSBundle(forClass:self.classForCoder).pathForResource(filename, ofType:"html") else {
            return
        }
        
        do {
            let html = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            guard let doc = HTML(html: html, encoding: NSUTF8StringEncoding) else {
                return
            }
            
            XCTAssert(doc.at_css("div#inner")!.innerHTML == "\n        abc<div>def</div>hij<span>klmn</span>opq\n    ")
            XCTAssert(doc.at_css("#asd")!.innerHTML == "asd")
        } catch {
            XCTAssert(false, "File not found. name: (\(filename)), error: \(error)")
        }
    }
    
    func testNSURL() {
        guard let url = NSURL(string: "https://en.wikipedia.org/wiki/Cat"),
              let _ = HTML(url: url, encoding: NSUTF8StringEncoding) else {
            XCTAssert(false)
            return
        }
    }
}
