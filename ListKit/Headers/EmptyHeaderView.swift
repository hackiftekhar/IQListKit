//
//  EmptyHeaderView.swift
//  ListKit
//
//  Created by Iftekhar on 10/17/23.
//

import UIKit
import IQListKit

final class EmptyHeaderView: UIView, IQModelableSupplementaryView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.red
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor.red
    }

    var model: Model? {
        didSet {
//            guard let model = model else { return }
        }
    }

    struct Model: Hashable, @unchecked Sendable {
        let identifier: AnyHashable
        let height: CGFloat
    }

    static func size(for model: Model, listView: IQListView) -> CGSize? {
        return CGSize(width: listView.frame.width, height: model.height)
    }
}
