//
//  User.swift
//  ListKit
//
//  Created by Iftekhar on 29/12/20.
//

import Foundation

struct User: Hashable, Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        lhs.name == rhs.name
    }

    let name: String
}
