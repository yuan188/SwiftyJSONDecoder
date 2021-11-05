//
//  SwiftyJSONDecoder.swift
//  SwiftyJSONDecoder
//
//  Created by yuan188 on 11/03/2021.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import Foundation
import SwiftyJSON

public class SwiftyJSONDecoder: JSONDecoder {
    /// The strategy to use in decoding non-optional type for not found key or value. Defaults to `.automatically`.
    public enum NonOptionalDecodingStrategy {
        /// Throw upon encountering non-optional values.
        case `throw`

        /// Decode the non-optional object with a filling decoder. This is the default strategy.
        case automatically
    }

    public var nonOptionalDecodingStrategy: NonOptionalDecodingStrategy = .automatically

    struct Options {
        let dateDecodingStrategy: DateDecodingStrategy
        let dataDecodingStrategy: DataDecodingStrategy
        let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
        let keyDecodingStrategy: KeyDecodingStrategy
        let nonOptionalDecodingStrategy: NonOptionalDecodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }

    var options: Options {
        return Options(dateDecodingStrategy: dateDecodingStrategy,
                        dataDecodingStrategy: dataDecodingStrategy,
                        nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
                        keyDecodingStrategy: keyDecodingStrategy,
                        nonOptionalDecodingStrategy: nonOptionalDecodingStrategy,
                        userInfo: userInfo)
    }

    public override func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        var options: JSONSerialization.ReadingOptions = []
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            if allowsJSON5 {
                options.insert(.json5Allowed)
            }

            if assumesTopLevelDictionary {
                options.insert(.topLevelDictionaryAssumed)
            }
        }

        let json = try JSON(data: data, options: options)

        return try decode(type, from: json)
    }

    public func decode<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
        let data = Data(string.utf8)

        return try decode(type, from: data)
    }

    public func decode<T: Decodable>(_ type: T.Type, from json: JSON) throws -> T {
        let decoder = _SwiftyJSONDecoder(json: json, codingPath: [], options: options)

        return try decoder.singleValueContainer().decode(type)
    }
}

class _SwiftyJSONDecoder: Decoder {
    let json: JSON
    let options: SwiftyJSONDecoder.Options

    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] {
        return options.userInfo
    }

    init(json: JSON, codingPath: [CodingKey], options: SwiftyJSONDecoder.Options) {
        self.json = json
        self.options = options
        self.codingPath = codingPath
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        let keyedContainer = SwiftyJSONKeyedDecodingContainer<Key>(json: json, codingPath: codingPath, options: options)
        return KeyedDecodingContainer<Key>(keyedContainer)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return SwiftyJSONUnkeyedDecodingContainer(json: json, codingPath: codingPath, options: options)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}
