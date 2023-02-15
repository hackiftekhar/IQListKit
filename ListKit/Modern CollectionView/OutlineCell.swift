//
//  OutlineCell.swift
//  ListKit
//
//  Created by Iftekhar on 2/5/23.
//

import UIKit
import IQListKit

@available(iOS 14.0, *)
class OutlineCell: UICollectionViewListCell, IQModelableCell {

    typealias Model = OutlineViewController.OutlineItem

    var model: Model? {
        didSet {

            guard let model = model else { return }

            var contentConfiguration = defaultContentConfiguration()
            contentConfiguration.text = model.title

            if model.subitems.isEmpty {
                self.contentConfiguration = contentConfiguration

                accessories = []
            } else {
                contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
                self.contentConfiguration = contentConfiguration

                let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
                accessories = [.outlineDisclosure(options: disclosureOptions)]
            }
            backgroundConfiguration = UIBackgroundConfiguration.clear()
        }
    }
}
