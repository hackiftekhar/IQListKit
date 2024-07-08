//
//  IQListView.swift
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

@MainActor
@objc public protocol IQListView: Sendable where Self: UIScrollView {

    var backgroundView: UIView? { get }

    var indexPathsForSelectedItems: [IndexPath]? { get }
    func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: IQList.ScrollPosition)
    func reloadData()

    var numberOfSections: Int { get }
    func numberOfItems(inSection section: Int) -> Int

    func indexPathFor(cell: IQListCell) -> IndexPath?
//    func cellForItemAt(indexPath: IndexPath) -> IQListCell?
    var indexPathsForVisibleItems: [IndexPath] { get }
}

@MainActor
extension UICollectionView: IQListView {
    public func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: IQList.ScrollPosition) {
        selectItem(at: indexPath, animated: animated,
                   scrollPosition: scrollPosition.collectionViewScrollPosition)
    }

    public func indexPathFor(cell: IQListCell) -> IndexPath? {
        guard let cell = cell as? UICollectionViewCell else {
            return nil
        }
        return indexPath(for: cell)
    }

//    public func cellForItemAt(indexPath: IndexPath) -> IQListCell? {
//        cellForItem(at: indexPath)
//    }
}

@MainActor
extension UITableView: IQListView {
    public var indexPathsForSelectedItems: [IndexPath]? {
        indexPathsForSelectedRows
    }

    public func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: IQList.ScrollPosition) {
        selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition.tableViewScrollPosition)
    }

    public func numberOfItems(inSection section: Int) -> Int {
        numberOfRows(inSection: section)
    }

    public func indexPathFor(cell: IQListCell) -> IndexPath? {
        guard let cell = cell as? UITableViewCell else {
            return nil
        }
        return indexPath(for: cell)
    }

    public func cellForItemAt(indexPath: IndexPath) -> IQListCell? {
        cellForRow(at: indexPath)
    }

    public var indexPathsForVisibleItems: [IndexPath] {
        indexPathsForVisibleRows ?? []
    }
}
