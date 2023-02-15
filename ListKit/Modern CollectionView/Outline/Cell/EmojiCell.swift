//
//  EmojiCell.swift
//  ListKit
//
//  Created by Iftekhar on 2/7/23.
//

import UIKit
import IQListKit

@available(iOS 14.0, *)
class EmojiCell: UICollectionViewListCell, IQModelableCell {

    typealias Model = EmojiExplorerViewController.Item
    var model: Model? {
        didSet {
            guard let model = model else { return }

            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = model.emoji?.text
            contentConfiguration.secondaryText = String(describing: model.emoji?.category)
            self.contentConfiguration = contentConfiguration

            accessories = [.disclosureIndicator()]
        }
    }
}
