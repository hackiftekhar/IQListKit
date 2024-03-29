//
//  IQPlaceholderSupplementaryView.swift
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

// MARK: - A supplementary view for UITableView/UICollectionView

@MainActor
public final class IQSupplementaryViewPlaceholder: UIView, IQModelableSupplementaryView {
    public typealias Model = String

    public var model: Model?

    public static func size(for model: Model, listView: IQListView) -> CGSize? {

        if let listView = listView as? UICollectionView {
            if let layout = listView.collectionViewLayout as? UICollectionViewFlowLayout {
                let model: Model = model
                let sectionInset: UIEdgeInsets = layout.sectionInset
                let width: CGFloat = listView.frame.width - sectionInset.left - sectionInset.right
                let height: CGFloat = model.isEmpty ? 0 : 22
                return CGSize(width: width, height: height)
            }
        } else if let listView = listView as? UITableView {
            return CGSize(width: listView.frame.width, height: UITableView.automaticDimension)
        }
        return .zero
    }
}
