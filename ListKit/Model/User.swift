//
//  User.swift
//  ListKit
//
//  Created by Iftekhar on 29/12/20.
//

import Foundation

struct User: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    let id: Int
    let name: String
    let email: String
}
