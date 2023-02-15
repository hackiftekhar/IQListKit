//
//  ListAppearanceHeaderCell.swift
//  ListKit
//
//  Created by Iftekhar on 2/6/23.
//

import UIKit
import IQListKit

@available(iOS 14.0, *)
class ListAppearanceHeaderCell: UICollectionViewListCell, IQModelableCell {

    typealias Model = ListAppearancesViewController.Item
    var model: Model? {
        didSet {
            guard let model = model else { return }

            var content = defaultContentConfiguration()
            content.text = model.title
            contentConfiguration = content

            accessories = [.outlineDisclosure()]
        }
    }
}
