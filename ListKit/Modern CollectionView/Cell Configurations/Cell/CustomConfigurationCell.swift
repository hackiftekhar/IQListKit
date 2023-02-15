//
//  CustomConfigurationCell.swift
//  ListKit
//
//  Created by Iftekhar on 2/6/23.
//

import UIKit
import IQListKit

@available(iOS 14.0, *)
class CustomConfigurationCell: UICollectionViewCell, IQModelableCell {

    typealias Model = CustomConfigurationViewController.Item
    var model: Model? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        backgroundConfiguration = CustomBackgroundConfiguration.configuration(for: state)

        var content = CustomContentConfiguration().updated(for: state)
        content.image = model?.image
        contentConfiguration = content
    }
}
