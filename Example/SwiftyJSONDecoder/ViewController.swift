//
//  ViewController.swift
//  SwiftyJSONDecoder
//
//  Created by yuan188 on 11/03/2021.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import UIKit
import SwiftyJSONDecoder

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        struct Book: Codable {
            var title: String = ""
            var price: Int = 0
            var author: String?
            var isNew: Bool = false

            var type: BookType
            var icon: String

            enum CodingKeys: String, CodingKey {
                case title
                case price
                case author
                case isNew
                case type
                case icon = "icon.url"
            }
        }

        enum BookType: Int, Codable, DefaultCaseCodable {
            case history
            case action

            static var defaultCase: Self {
                return .history
            }
        }

        let json = """
{
    "title": "ABCDEF",
    "price": 10,
    "isNew": 1,
    "author": null,
    "type": 1,
    "icon": {
        "url": "icon_url"
    }
}
"""
        do {
            let book = try SwiftyJSONDecoder().decode(Book.self, from: json)
            debugPrint("title: \(book.title)")
            debugPrint("price: \(book.price)")
            debugPrint("isNew: \(book.isNew)")
            debugPrint("author: \(book.author)")
            debugPrint("type: \(book.type)")
            debugPrint("icon: \(book.icon)")
        } catch {
            debugPrint("error: \(error)")
        }
    }
}

