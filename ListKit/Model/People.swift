//
//  People.swift
//  ListKit
//
//  Created by Iftekhar on 30/12/20.
//

import Foundation

struct People: Hashable, Comparable {
    static func < (lhs: People, rhs: People) -> Bool {
        lhs.name == rhs.name
    }

    let name: String
}
