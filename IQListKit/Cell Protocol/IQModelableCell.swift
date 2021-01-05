//
//  IQModelableCell.swift
//  https://github.com/hackiftekhar/IQListKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

// MARK: Main Modelable Cell Protocol

public protocol IQModelableCell: IQModelModifiable, IQCellSizeProvider,
                                 IQSelectableCell, IQCellActionsProvider {

    // Dynamic model which should be implemented in cells confirming the IQModelableCell
    associatedtype Model: Hashable

    // model variable which will be used to configure the cell contents
    var model: Model? { get set }
}

// MARK: Default implementations of confirmed protocols

public extension IQModelableCell {

    func setModel(_ newValue: AnyHashable?) {
        self.model = newValue as? Model
    }
}

public extension IQModelableCell {

    static func estimatedSize(for model: AnyHashable?, listView: IQListView) -> CGSize {
        return size(for: model, listView: listView)
    }

    static func size(for model: AnyHashable?, listView: IQListView) -> CGSize {
        if let clv = listView as? UICollectionView, let cvfl = clv.collectionViewLayout as? UICollectionViewFlowLayout {
            return CGSize(width: clv.frame.width - cvfl.sectionInset.left - cvfl.sectionInset.right, height: 0)
        }
        return CGSize(width: UITableView.automaticDimension, height: UITableView.automaticDimension)
    }
}

public extension IQModelableCell {

    var isHighlightable: Bool { true }

    var isSelectable: Bool { true }
}

public extension IQCellActionsProvider {

    @available(iOS 11.0, *)
    func leadingSwipeActions() -> [IQContextualAction]? { return nil }

    func trailingSwipeActions() -> [IQContextualAction]? { return nil }

    @available(iOS 13.0, *)
    func contextMenuConfiguration() -> UIContextMenuConfiguration? { return nil }

    @available(iOS 13.0, *)
    func contextMenuPreviewView(configuration: UIContextMenuConfiguration) -> UIView? { return nil }

    @available(iOS 13.0, *)
    func performPreviewAction(configuration: UIContextMenuConfiguration,
                              animator: UIContextMenuInteractionCommitAnimating) {}
}
