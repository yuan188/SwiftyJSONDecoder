//
//  SwiftyJSONUnkeyedDecodingContainer.swift
//  SwiftyJSONDecoder
//
//  Created by yuan188 on 11/03/2021.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SwiftyJSONUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    let json: JSON
    let options: SwiftyJSONDecoder.Options
    var codingPath: [CodingKey] = []

    var count: Int? {
        return json.arrayValue.count
    }

    var isAtEnd: Bool {
        return currentIndex >= (count ?? 0)
    }

    var currentIndex: Int = 0

    init(json: JSON, codingPath: [CodingKey], options: SwiftyJSONDecoder.Options) {
        self.json = json
        self.options = options
        self.codingPath = codingPath
    }

    mutating func decode(_ type: String.Type) throws -> String {
        return try _decode(type)
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        return try _decode(type)
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        return try _decode(type)
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        return try _decode(type)
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        return try _decode(type)
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        return try _decode(type)
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        return try _decode(type)
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        return try _decode(type)
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        return try _decode(type)
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try _decode(type)
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try _decode(type)
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try _decode(type)
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try _decode(type)
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        return try _decode(type)
    }

    mutating func decodeNil() throws -> Bool {
        let decoder = try superDecoder()
        return try decoder.singleValueContainer().decodeNil()
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        let decoder = try superDecoder()
        return try decoder.container(keyedBy: type)
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let decoder = try superDecoder()
        return try decoder.unkeyedContainer()
    }

    mutating func superDecoder() throws -> Decoder {
        guard !isAtEnd else {
            throw NSError()
        }

        let json = json[currentIndex]
        defer {
            currentIndex += 1
        }

        return _SwiftyJSONDecoder(json: json, codingPath: codingPath + [SwiftyJSONKey(index: currentIndex)], options: options)
    }

    @inline(__always)
    private mutating func _decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        let decoder = try superDecoder()
        return try decoder.singleValueContainer().decode(type)
    }
}
