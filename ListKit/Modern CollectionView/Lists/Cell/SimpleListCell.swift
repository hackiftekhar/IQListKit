//
//  SimpleListCell.swift
//  ListKit
//
//  Created by Iftekhar on 2/6/23.
//

import UIKit
import IQListKit

@available(iOS 14.0, *)
class SimpleListCell: UICollectionViewListCell, IQModelableCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    struct Model: Hashable {
        let section: UUID
        let text: String
    }

    var model: Model? {
        didSet {
            guard let model = model else { return }

            var content = defaultContentConfiguration()
            content.text = model.text
            contentConfiguration = content
        }
    }
}
