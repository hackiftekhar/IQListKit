//
//  Book.swift
//  ListKit
//
//  Created by Iftekhar on 30/12/20.
//

import Foundation

struct Book: Hashable, Comparable {
    static func < (lhs: Book, rhs: Book) -> Bool {
        lhs.name == rhs.name
    }

    let id: Int
    let name: String
}
