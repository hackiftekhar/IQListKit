//
//  InsertionCell.swift
//  ListKit
//
//  Created by Iftekhar on 04/01/21.
//

import UIKit
import IQListKit

class InsertionCell: UICollectionViewCell, IQModelableCell {

    var model: Node? {
        didSet {
            backgroundColor = model?.color
        }
    }

    static func estimatedSize(for model: AnyHashable?, listView: IQListView) -> CGSize {
        return size(for: model, listView: listView)
    }

    static func size(for model: AnyHashable?, listView: IQListView) -> CGSize {
        return CGSize(width: 16, height: 16)
    }
}
