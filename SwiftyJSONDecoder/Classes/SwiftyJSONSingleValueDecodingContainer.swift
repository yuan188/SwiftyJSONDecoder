//
//  SwiftyJSONSingleValueDecodingContainer.swift
//  SwiftyJSONDecoder
//
//  Created by yuan188 on 11/03/2021.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import Foundation
import SwiftyJSON

extension _SwiftyJSONDecoder: SingleValueDecodingContainer {
    func decodeNil() -> Bool {
        return json.null != nil
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        try checkNullDecodingStrategy(type)

        return json.boolValue
    }

    func decode(_ type: String.Type) throws -> String {
        try checkNullDecodingStrategy(type)

        return json.stringValue
    }

    func decode(_ type: Double.Type) throws -> Double {
        try checkNullDecodingStrategy(type)

        let string = try decode(String.self)
        if isInfinity(string: string) {
            return .infinity
        } else if isNegInfinity(string: string) {
            return -Double.infinity
        } else if isNan(string: string) {
            return .nan
        } else {
            return json.doubleValue
        }
    }

    func decode(_ type: Float.Type) throws -> Float {
        try checkNullDecodingStrategy(type)

        let string = try decode(String.self)
        if isInfinity(string: string) {
            return .infinity
        } else if isNegInfinity(string: string) {
            return -Float.infinity
        } else if isNan(string: string) {
            return .nan
        } else {
            return json.floatValue
        }
    }

    func decode(_ type: Int.Type) throws -> Int {
        try checkNullDecodingStrategy(type)

        return json.intValue
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try checkNullDecodingStrategy(type)

        return json.int8Value
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try checkNullDecodingStrategy(type)

        return json.int16Value
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try checkNullDecodingStrategy(type)

        return json.int32Value
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try checkNullDecodingStrategy(type)

        return json.int64Value
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        try checkNullDecodingStrategy(type)

        return json.uIntValue
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try checkNullDecodingStrategy(type)

        return json.uInt8Value
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try checkNullDecodingStrategy(type)

        return json.uInt16Value
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return json.uInt32Value
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try checkNullDecodingStrategy(type)

        return json.uInt64Value
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        try checkNullDecodingStrategy(type)
        
        if type == Date.self || type == NSDate.self {
            return try decode(Date.self) as! T
        } else if type == Data.self || type == NSData.self {
            return try decode(Data.self) as! T
        } else if type == URL.self || type == NSURL.self {
            guard let url = json.url else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath,
                                                                        debugDescription: "Invalid URL string."))
            }

            return url as! T
        } else if type == Decimal.self || type == NSDecimalNumber.self {
            return json.numberValue as! T
        } else {
            return try T(from: self)
        }
    }

    func decode(_ type: Date.Type) throws -> Date {
        switch options.dateDecodingStrategy {
        case .deferredToDate:
            let date = try Date(from: self)
            return date

        case .secondsSince1970:
            let double = try decode(Double.self)
            return Date(timeIntervalSince1970: double)

        case .millisecondsSince1970:
            let double = try decode(Double.self)
            return Date(timeIntervalSince1970: double / 1000.0)

        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                let string = try decode(String.self)
                guard let date = _iso8601Formatter.date(from: string) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
                }

                return date
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }

        case .formatted(let formatter):
            let string = try decode(String.self)
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date string does not match format expected by formatter."))
            }

            return date

        case .custom(let closure):
            let date = try closure(self)
            return date

        @unknown default:
            let date = try Date(from: self)
            return date
        }
    }

    func decode(_ type: Data.Type) throws -> Data {
        switch self.options.dataDecodingStrategy {
        case .deferredToData:
            let data = try Data(from: self)
            return data

        case .base64:
            let string = try decode(String.self)

            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }

            return data

        case .custom(let closure):
            let data = try closure(self)
            return data

        @unknown default:
            let data = try Data(from: self)
            return data
        }
    }

    private func checkNullDecodingStrategy<T>(_ type: T.Type) throws {
        guard json == .null, options.nonOptionalDecodingStrategy == .throw else {
            return
        }

        throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: codingPath, debugDescription: "No value associated with key"))
    }

    private func isInfinity(string: String) -> Bool {
        return ["infinity", "inf"].contains(string.lowercased())
    }

    private func isNegInfinity(string: String) -> Bool {
        return ["-infinity", "-inf"].contains(string.lowercased())
    }

    private func isNan(string: String) -> Bool {
        return "nan" == string.lowercased()
    }
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
private var _iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()
