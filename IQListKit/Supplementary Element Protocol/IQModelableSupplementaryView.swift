//
//  IQModelableHeader.swift
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

public protocol IQModelableSupplementaryView: IQModelModifiable, IQViewSizeProvider
where Self: UIView {

    /// Dynamic model which should be implemented in cells confirming the IQModelableCell
    associatedtype Model: Hashable

    /// model variable which will be used to configure the cell contents
    var model: Model? { get set }
}

public extension IQModelableSupplementaryView {

    func setModel(_ model: AnyHashable?) {
        self.model = model as? Model
    }
}

public extension IQModelableSupplementaryView {

    static func estimatedSize(for model: AnyHashable?, listView: IQListView) -> CGSize {
        return size(for: model, listView: listView)
    }

    static func size(for model: AnyHashable?, listView: IQListView) -> CGSize {
        if let listView = listView as? UICollectionView {
            if let cvfl = listView.collectionViewLayout as? UICollectionViewFlowLayout {
                return CGSize(width: listView.frame.width - cvfl.sectionInset.left - cvfl.sectionInset.right, height: 22)
            }
        } else if let listView = listView as? UITableView {
            return CGSize(width: listView.frame.width, height: UITableView.automaticDimension)
        }
        return .zero
    }

    static func indentationLevel(for model: AnyHashable?, listView: IQListView) -> Int {
        return 0
    }
}
