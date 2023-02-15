//
//  ReorderingListCell.swift
//  ListKit
//
//  Created by Iftekhar on 2/6/23.
//

import UIKit
import IQListKit

@available(iOS 14.0, *)
class ReorderingListCell: UICollectionViewListCell, IQModelableCell {

    typealias Model = ReorderableListViewController.Item
    var model: Model? {
        didSet {
            guard let model = model else { return }

            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = model.emoji.text
            contentConfiguration.secondaryText = String(describing: model.emoji.category)
            self.contentConfiguration = contentConfiguration
            accessories = [.disclosureIndicator(), .reorder(displayed: .always)]
        }
    }
}
