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

    let id: Int
    let name: String
    let email: String
}
