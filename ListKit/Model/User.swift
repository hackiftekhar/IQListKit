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
        hasher.combine(name)
        hasher.combine(email)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.email == rhs.email
    }

    let id: Int
    let name: String
    let email: String
}
