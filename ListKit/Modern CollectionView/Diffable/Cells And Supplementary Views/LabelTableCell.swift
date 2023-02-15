//
//  LabelTableCell.swift
//  ListKit
//
//  Created by Iftekhar on 2/4/23.
//

import UIKit
import IQListKit

final class LabelTableCell: UITableViewCell, IQModelableCell {

    static private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    @IBOutlet var label: UILabel!

    var model: MountainsController.Mountain? {
        didSet {

            guard let model = model else { return }

            if let formattedHeight = Self.formatter.string(from: NSNumber(value: model.height)) {
                label.text = model.name + ", Height: \(formattedHeight)M"
            } else {
                label.text = model.name
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.borderWidth = 1
        layer.cornerRadius = 16
        layer.borderColor = UIColor.lightGray.cgColor
    }

    override var editingStyle: UITableViewCell.EditingStyle {
        return .delete
    }
}
