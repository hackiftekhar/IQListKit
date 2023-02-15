//
//  ListAppearanceItemCell.swift
//  ListKit
//
//  Created by Iftekhar on 2/6/23.
//

import UIKit
import IQListKit

@available(iOS 14.0, *)
class ListAppearanceItemCell: UICollectionViewListCell, IQModelableCell {

    struct Model: Hashable {
        let item: ListAppearancesViewController.Item
        let appearance: UICollectionLayoutListConfiguration.Appearance
    }

    var model: Model? {
        didSet {
            guard let model = model else { return }

            var content = defaultContentConfiguration()
            content.text = model.item.title
            contentConfiguration = content

            switch model.appearance {
            case .sidebar, .sidebarPlain:
                accessories = []
            default:
                accessories = [.disclosureIndicator()]
            }
        }
    }
}
