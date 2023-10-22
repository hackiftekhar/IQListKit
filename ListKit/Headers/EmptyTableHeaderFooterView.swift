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

    public static func estimatedSize(for model: AnyHashable, listView: IQListView) -> CGSize? {
        size(for: model, listView: listView)
    }

    public static func size(for model: AnyHashable, listView: IQListView) -> CGSize? {
        return CGSize(width: listView.frame.width, height: 22)
    }
}
