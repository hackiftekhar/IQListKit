//
//  InsertionCell.swift
//  ListKit
//
//  Created by Iftekhar on 04/01/21.
//

import UIKit
import IQListKit

class InsertionCell: UICollectionViewCell, IQModelableCell {

    typealias Model = Node
    var model: Model? {
        didSet {
            backgroundColor = model?.color
        }
    }

    static func size(for model: Model, listView: IQListView) -> CGSize? {
        return CGSize(width: 16, height: 16)
    }
}
