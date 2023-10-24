//
//  EmptyTableHeaderFooterView.swift
//  ListKit
//
//  Created by Iftekhar on 10/22/23.
//

import UIKit
import IQListKit

@MainActor
public final class EmptyTableHeaderFooterView: UITableViewHeaderFooterView, IQModelableSupplementaryView {
    public typealias Model = String

    public var model: Model? {
        didSet {
            textLabel?.text = model
        }
    }

    public static func size(for model: Model, listView: IQListView) -> CGSize? {
        return CGSize(width: listView.frame.width, height: 22)
    }
}
