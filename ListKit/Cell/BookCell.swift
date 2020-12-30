//
//  BookCell.swift
//  ListKit
//
//  Created by Iftekhar on 30/12/20.
//

import Foundation
import IQListKit

class BookCell: UITableViewCell, IQModelableCell {

    typealias Model = Book

    var model: Model? {
        didSet {
            textLabel?.text = model?.name
            detailTextLabel?.text = "Loaded using Storyboard"
        }
    }
}
