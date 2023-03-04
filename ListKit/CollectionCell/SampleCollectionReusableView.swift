//
//  SampleCollectionReusableView.swift
//  ListKit
//
//  Created by Iftekhar on 26/11/21.
//

import UIKit
import IQListKit

class SampleCollectionReusableView: UICollectionReusableView, IQModelableSupplementaryView {

    struct Model: Hashable {
        let color: UIColor
    }

    var model: Model? {
        didSet {
            guard let model = model else { return }
            self.backgroundColor = model.color
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func size(for model: AnyHashable?, listView: IQListView) -> CGSize {
        return CGSize(width: listView.frame.width, height: 22)
    }
}
