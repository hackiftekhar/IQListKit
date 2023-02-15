//
//  ItemListCell.swift
//  ListKit
//
//  Created by Iftekhar on 2/6/23.
//

import UIKit
import IQListKit

@available(iOS 14.0, *)
class ItemListCell: UICollectionViewListCell, IQModelableCell {
    typealias Model = CustomCellListViewController.Item

    var model: Model? {
        didSet {
            guard let model = model, model != oldValue else { return }
            guard model != oldValue else { return }
            setNeedsUpdateConfiguration()
        }
    }

    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.model = self.model
        return state
    }
}

@available(iOS 14.0, *)
extension UICellConfigurationState {
    var model: ItemListCell.Model? {
        set { self[.model] = newValue }
        get { return self[.model] as? ItemListCell.Model }
    }
}

@available(iOS 14.0, *)
extension UIConfigurationStateCustomKey {
    static let model = UIConfigurationStateCustomKey("com.apple.ItemListCell.model")
}
