//
//  IQList+Info.swift
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

// MARK: - Update the list
/// Note that all these methods can also be used in a background threads since they all
/// methods deal with the models, not any UI elements.
/// NSDiffableDataSourceSnapshot.apply is also background thread safe
public extension IQList {

    enum ScrollPosition: Int {
        case none = 0
        case top = 1
        case center = 2
        case bottom = 3
        case left = 4
        case right = 5

        fileprivate var tableViewScrollPosition: UITableView.ScrollPosition {
            switch self {
            case .none, .left, .right:
                return .none
            case .top:
                return .top
            case .center:
                return .middle
            case .bottom:
                return .bottom
            }
        }

        fileprivate var collectionViewScrollPosition: UICollectionView.ScrollPosition {
            switch self {
            case .none:
                return []
            case .top:
                return .top
            case .center:
                return [.centeredVertically, .centeredHorizontally]
            case .bottom:
                return .bottom
            case .left:
                return .left
            case .right:
                return .right
            }
        }
    }

    var numberOfItems: Int {
        diffableDataSource.snapshot().numberOfItems
    }

    var numberOfSections: Int {
        diffableDataSource.snapshot().numberOfSections
    }

    var sectionIdentifiers: [IQSection] {
        diffableDataSource.snapshot().sectionIdentifiers
    }

    var itemIdentifiers: [IQItem] {
        diffableDataSource.snapshot().itemIdentifiers
    }

    func numberOfItems(inSection identifier: IQSection) -> Int {
        diffableDataSource.snapshot().numberOfItems(inSection: identifier)
    }

    func itemIdentifiers(inSection identifier: IQSection) -> [IQItem] {
        diffableDataSource.snapshot().itemIdentifiers(inSection: identifier)
    }

    func sectionIdentifier(where predicate: (IQSection) -> Bool) -> IQSection? {
        diffableDataSource.snapshot().sectionIdentifiers.first(where: predicate)
    }

    func sectionIdentifier(containingItem identifier: IQItem) -> IQSection? {
        diffableDataSource.snapshot().sectionIdentifier(containingItem: identifier)
    }

    func indexPath(for identifier: IQItem) -> IndexPath? {
        diffableDataSource.indexPath(for: identifier)
    }

    func itemIdentifier(for indexPath: IndexPath) -> IQItem? {
        diffableDataSource.itemIdentifier(for: indexPath)
    }

    func itemIdentifier<T: IQModelableCell>(of type: T.Type, where predicate: (T.Model) -> Bool) -> IQItem? {

        if let item = diffableDataSource.snapshot().itemIdentifiers.first(where: {
            if let existingModel = $0.model as? T.Model {
                return predicate(existingModel)
            }
            return false
        }) {
            return item
        }

        return nil
    }

    func itemIdentifier(where predicate: (IQItem) -> Bool) -> IQItem? {
        diffableDataSource.snapshot().itemIdentifiers.first(where: predicate)
    }

    func scrollTo(item: IQItem, at scrollPosition: IQList.ScrollPosition, animated: Bool) {

        guard let indexPath = indexPath(for: item) else {
            return
        }

        if let tableView = listView as? UITableView {
            tableView.scrollToRow(at: indexPath,
                                  at: scrollPosition.tableViewScrollPosition,
                                  animated: animated)
        } else if let collectionView = listView as? UICollectionView {
            collectionView.scrollToItem(at: indexPath,
                                        at: scrollPosition.collectionViewScrollPosition,
                                        animated: animated)
        }
    }
}
