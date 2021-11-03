//
//  DefaultCaseCodable.swift
//  SwiftyJSONDecoder
//
//  Created by yuan188 on 11/03/2021.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import Foundation

public protocol DefaultCaseCodable: RawRepresentable {
    static var defaultCase: Self { get }
}

public extension DefaultCaseCodable where Self: Decodable, Self.RawValue: Decodable {
    init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer(),
            let rawValue = try? container.decode(RawValue.self) else {
            self = Self.defaultCase
            return
        }

        self = Self.init(rawValue: rawValue) ?? Self.defaultCase
    }
}

public protocol DecodingKeysMapCodable {
    static var decodingKeysMap: [String: String] { get }
}
