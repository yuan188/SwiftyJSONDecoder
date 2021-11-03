//
//  SwiftyJSONKeyedDecodingContainer.swift
//  SwiftyJSONDecoder
//
//  Created by yuan188 on 11/03/2021.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SwiftyJSONKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let json: JSON
    let options: SwiftyJSONDecoder.Options
    var codingPath: [CodingKey] = []

    init(json: JSON, codingPath: [CodingKey], options: SwiftyJSONDecoder.Options) {
        self.options = options
        self.codingPath = codingPath

        switch options.keyDecodingStrategy {
        case .useDefaultKeys:
            self.json = json
        case .convertFromSnakeCase:

            let dictionaryObject = json.dictionaryObject ?? [:]
            let dictionary = Dictionary(dictionaryObject.map {
                key, value in (Self._convertFromSnakeCase(key), value)
            }, uniquingKeysWith: { (first, _) in first })

            self.json = JSON(dictionary)
        case .custom(let converter):
            let dictionaryObject = json.dictionaryObject ?? [:]
            let dictionary = Dictionary(dictionaryObject.map {
                key, value in (converter(codingPath + [SwiftyJSONKey(stringValue: key, intValue: nil)]).stringValue, value)
            }, uniquingKeysWith: { (first, _) in first })

            self.json = JSON(dictionary)
        @unknown default:
            self.json = json
        }
    }

    var allKeys: [Key] {
        return json.dictionaryValue.keys.compactMap { Key(stringValue: $0) }
    }

    func contains(_ key: Key) -> Bool {
        return json.contains(where: { $0.0 == key.stringValue })
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        let decoder = try superDecoder(forKey: key)
        return try decoder.singleValueContainer().decodeNil()
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        return try _decode(type, forKey: key)
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        return try _decode(type, forKey: key)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        return try _decode(type, forKey: key)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        return KeyedDecodingContainer<NestedKey>(SwiftyJSONKeyedDecodingContainer<NestedKey>(json: json[key.stringValue], codingPath: codingPath, options: options))
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        let decoder = try superDecoder(forKey: key)
        return try decoder.unkeyedContainer()
    }

    func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: SwiftyJSONKey.super)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }

    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        let keyvalue = key.stringValue

        let subjson: JSON
        if json.contains(where: { $0.0 == keyvalue }) {
            subjson = json[keyvalue]
        } else {
            let keys = keyvalue.split(separator: ".").map { String.init($0) }
            subjson = json[keys]
        }

        return _SwiftyJSONDecoder(json: subjson, codingPath: codingPath + [key], options: options)
    }

    private func _decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        let decoder = try superDecoder(forKey: key)
        return try decoder.singleValueContainer().decode(type)
    }

    private static func _convertFromSnakeCase(_ stringKey: String) -> String {
        guard !stringKey.isEmpty else { return stringKey }

        // Find the first non-underscore character
        guard let firstNonUnderscore = stringKey.firstIndex(where: { $0 != "_" }) else {
            // Reached the end without finding an _
            return stringKey
        }

        // Find the last non-underscore character
        var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
        while lastNonUnderscore > firstNonUnderscore && stringKey[lastNonUnderscore] == "_" {
            stringKey.formIndex(before: &lastNonUnderscore)
        }

        let keyRange = firstNonUnderscore...lastNonUnderscore
        let leadingUnderscoreRange = stringKey.startIndex..<firstNonUnderscore
        let trailingUnderscoreRange = stringKey.index(after: lastNonUnderscore)..<stringKey.endIndex

        let components = stringKey[keyRange].split(separator: "_")
        let joinedString: String
        if components.count == 1 {
            // No underscores in key, leave the word as is - maybe already camel cased
            joinedString = String(stringKey[keyRange])
        } else {
            joinedString = ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
        }

        // Do a cheap isEmpty check before creating and appending potentially empty strings
        let result: String
        if (leadingUnderscoreRange.isEmpty && trailingUnderscoreRange.isEmpty) {
            result = joinedString
        } else if (!leadingUnderscoreRange.isEmpty && !trailingUnderscoreRange.isEmpty) {
            // Both leading and trailing underscores
            result = String(stringKey[leadingUnderscoreRange]) + joinedString + String(stringKey[trailingUnderscoreRange])
        } else if (!leadingUnderscoreRange.isEmpty) {
            // Just leading
            result = String(stringKey[leadingUnderscoreRange]) + joinedString
        } else {
            // Just trailing
            result = joinedString + String(stringKey[trailingUnderscoreRange])
        }
        return result
    }
}
