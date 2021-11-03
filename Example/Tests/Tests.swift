// https://github.com/Quick/Quick

import Quick
import Nimble
import SwiftyJSONDecoder
import Foundation

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("Decode JSON") {
            struct Book: Codable {
                var title: String = ""
                var price: Int = 0
                var author: String?
                var isNew: Bool = false
                var tags: [Int] = []
            }

            it("Model") {
                let json = """
{
    "title": "ABCDEF",
    "price": 10,
    "isNew": 1,
    "author": null,
    "tags": [1, 2, 3, 4]
}
"""
                do {
                    let book = try SwiftyJSONDecoder().decode(Book.self, from: json)
                    expect(book.title) == "ABCDEF"
                    expect(book.price) == 10
                    expect(book.isNew) == true
                    expect(book.author == nil) == true
                    expect(book.tags) == [1, 2, 3, 4]
                } catch {
                    fail("解析失败")
                }
            }

            it("Bool") {
                let json = """
[1, "yes", "y", true, 0, 10, false, "bcd"]
"""
                do {
                    let values = try SwiftyJSONDecoder().decode([Bool].self, from: json)
                    expect(values) == [true, true, true, true, false, true, false, false]
                } catch {
                    fail("解析失败")
                }
            }

            it("Int") {
                let json = """
[1, "1", true, "abc"]
"""
                do {
                    let values = try SwiftyJSONDecoder().decode([Int].self, from: json)
                    expect(values) == [1, 1, 1, 0]
                } catch {
                    fail("解析失败")
                }
            }

            it("String") {
                let json = """
[1, "10", true]
"""
                do {
                    let values = try SwiftyJSONDecoder().decode([String].self, from: json)
                    expect(values) == ["1", "10", "true"]
                } catch {
                    fail("解析失败")
                }
            }

            it("Double") {
                let json = """
[1, "infinity", "-infinity", "ohter"]
"""
                do {
                    let values = try SwiftyJSONDecoder().decode([Double].self, from: json)
                    expect(values) == [1.0, .infinity, -Double.infinity, 0.0]
                } catch {
                    fail("解析失败")
                }
            }

            it("Float") {
                let json = """
[1, "infinity", "-infinity", "ohter"]
"""
                do {
                    let values = try SwiftyJSONDecoder().decode([Float].self, from: json)
                    expect(values) == [1.0, .infinity, -Float.infinity, 0.0]
                } catch {
                    fail("解析失败")
                }
            }

            it("Option") {
                let json = """
[1, "10", true, null,]
"""
                do {
                    let values = try SwiftyJSONDecoder().decode([String?].self, from: json)
                    expect(values) == ["1", "10", "true", nil]
                } catch {
                    fail("解析失败")
                }
            }

            it("enum") {
                enum BookType: Int, Codable, DefaultCaseCodable {
                    case history
                    case action

                    static var defaultCase: Self {
                        return .history
                    }
                }

                let json = """
[0, 1, 2, ""]
"""
                do {
                    let values = try SwiftyJSONDecoder().decode([BookType].self, from: json)
                    expect(values) == [.history, .action, .history, .history]
                } catch {
                    fail("解析失败")
                }
            }

            it("date") {
                let json = """
[0, 10000, 2, ""]
"""
                do {
                    let decoder = SwiftyJSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let values = try decoder.decode([Date].self, from: json)
                    expect(values) == [Date(timeIntervalSince1970: 0), Date(timeIntervalSince1970: 10000), Date(timeIntervalSince1970: 2), Date(timeIntervalSince1970: 0)]
                } catch {
                    fail("解析失败")
                }
            }

            it("data") {
                let json = """
["ABC=="]
"""
                do {
                    let decoder = SwiftyJSONDecoder()
                    decoder.dataDecodingStrategy = .base64
                    let values = try decoder.decode([Data].self, from: json)
                    expect(values) == [Data(base64Encoded: "ABC==")]
                } catch {
                    fail("解析失败")
                }
            }

            it("url") {
                let json = """
["https://www.baidu.com/"]
"""
                do {
                    let decoder = SwiftyJSONDecoder()
                    let values = try decoder.decode([URL].self, from: json)
                    expect(values) == [URL(string: "https://www.baidu.com/")!]
                } catch {
                    fail("解析失败")
                }
            }

            it("keypath") {
                struct A: Codable {
                    var value: String
                    enum CodingKeys: String, CodingKey {
                        case value = "A.B.C.D.F"
                    }
                }

                let json = """
{"A": {"B": {"C": {"D": {"F": "ABCDEFG"}}}}}
"""
                do {
                    let value = try SwiftyJSONDecoder().decode(A.self, from: json)
                    expect(value.value) == "ABCDEFG"
                } catch {
                    fail("解析失败")
                }
            }

            it("snakeCase") {
                struct A: Codable {
                    var valueAb: String
                }

                let json = """
{"value_ab": "ABCDFG"}
"""
                do {
                    let decoder = SwiftyJSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let value = try decoder.decode(A.self, from: json)
                    expect(value.valueAb) == "ABCDFG"
                } catch {
                    fail("解析失败")
                }
            }

            it("nonOptionalDecodingStrategy") {
                struct A: Codable {
                    var a: String
                    var b: String
                }

                let json = """
{"a": null, "b": "b"}
"""
                let decoder = SwiftyJSONDecoder()
                decoder.nonOptionalDecodingStrategy = .throw
                let value = try? decoder.decode(A.self, from: json)
                expect(value == nil) == true

                let json2 = """
{"a": "null", "b": "b"}
"""
                let value2 = try? decoder.decode(A.self, from: json2)
                expect(value2 != nil) == true
            }
        }
    }
}
