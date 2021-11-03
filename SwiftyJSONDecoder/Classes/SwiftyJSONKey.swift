//
//  JSONKey.swift
//  SwiftyJSONDecoder
//
//  Created by yuan188 on 2021/11/4.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import Foundation

struct SwiftyJSONKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    static let `super` = SwiftyJSONKey(stringValue: "super")!
}
