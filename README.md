# SwiftyJSONDecoder

[![CI Status](https://img.shields.io/travis/yuan188/SwiftyJSONDecoder.svg?style=flat)](https://travis-ci.org/yuan188/SwiftyJSONDecoder)
[![Version](https://img.shields.io/cocoapods/v/SwiftyJSONDecoder.svg?style=flat)](https://cocoapods.org/pods/SwiftyJSONDecoder)
[![License](https://img.shields.io/cocoapods/l/SwiftyJSONDecoder.svg?style=flat)](https://cocoapods.org/pods/SwiftyJSONDecoder)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyJSONDecoder.svg?style=flat)](https://cocoapods.org/pods/SwiftyJSONDecoder)

## 功能

继承自 `JSONDecoder`，在标准库源码基础上做了改动，与其主要区别如下

+ 使用 [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) 解析数据，使用其类型兼容功能
+ 废弃 `nonConformingFloatDecodingStrategy` 属性设置，`Double` 及 `Float` 默认解析 `inf` `infinity` `-inf` `-infinity` `nan`数据
+ 增加新策略 `nonOptionalDecodingStrategy`，默认为 `automatically`
    + `automatically`：当解析非optional类型时，其值为 null，自动填充默认值
    + `throw`：当解析非optional类型时，其值为 null，抛出异常
+ 增加 `DefaultCaseCodable` 协议，当 `enum` 实现此协议，当解析失败时将使用此默认值
+ `CodingKey` 支持用 `.` 分割 `keypath`，从而通过 `keypath` 解析数据

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage
`SwiftyJSONDecoder` 直接替换 `JSONDecoder`

### Import
```swift 
import SwiftyJSONDecoder
```

### Normal
```swift
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
```

### DefaultCaseCodable
```swift 
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
```

### CodingKey 支持 keypath
```swift 
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
```

## Requirements

iOS 9+
Swift 5.0+
Xcode 13(如需在以下版本使用，可使用 1.0 版本)

## Installation

SwiftyJSONDecoder is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftyJSONDecoder'
```

## License

SwiftyJSONDecoder is available under the MIT license. See the LICENSE file for more info.
