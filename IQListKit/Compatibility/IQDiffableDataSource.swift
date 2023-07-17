//
//  IQDiffableDataSource.swift
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

internal protocol IQDiffableDataSource
where Self: UIScrollViewDelegate {

    var registeredCells: [IQListCell.Type] { get set }
    var registeredSupplementaryViews: [String: [UIView.Type]] { get set }

    var proxyDelegate: IQListViewProxyDelegate? { get set }
    var delegate: IQListViewDelegate? { get set }
    var dataSource: IQListViewDataSource? { get set }
    var clearsSelectionOnDidSelect: Bool { get set }
    var defaultRowAnimation: UITableView.RowAnimation { get set }

    func snapshot() -> IQList.IQDiffableDataSourceSnapshot

    func itemIdentifier(for indexPath: IndexPath) -> IQItem?
    func indexPath(for itemIdentifier: IQItem) -> IndexPath?

    @available(iOS 15.0, tvOS 15.0, *)
    func applySnapshotUsingReloadData(_ snapshot: IQList.IQDiffableDataSourceSnapshot,
                                      completion: (() -> Void)?)

    func apply(_ snapshot: IQList.IQDiffableDataSourceSnapshot,
               animatingDifferences: Bool,
               completion: (() -> Void)?)

    // For UICollectionView only
    @available(iOS 14.0, *)
    func apply(_ snapshot: IQList.IQDiffableDataSourceSectionSnapshot, to section: IQSection,
               animatingDifferences: Bool,
               completion: (() -> Void)?)

    @available(iOS 14.0, *)
    func snapshot(for section: IQSection) -> IQList.IQDiffableDataSourceSectionSnapshot
}

extension IQCollectionViewDiffableDataSource: IQDiffableDataSource {
    var defaultRowAnimation: UITableView.RowAnimation {
        get {
            return .automatic
        }
        set {
            print("defaultRowAnimation \(newValue) is not supported in UICollectionView")
            // Not supported
        }
    }
}

extension IQTableViewDiffableDataSource: IQDiffableDataSource {
    @available(iOS 14.0, *)
    func apply(_ snapshot: IQList.IQDiffableDataSourceSectionSnapshot, to section: IQSection,
               animatingDifferences: Bool, completion: (() -> Void)?) {
        // doesn't have any effect
        fatalError("Section snapshot isn't supported for UITableView")
    }

    @available(iOS 14.0, *)
    func snapshot(for section: IQSection) -> IQList.IQDiffableDataSourceSectionSnapshot {
        // doesn't have any effect
        fatalError("Section snapshot isn't supported for UITableView")
    }
}
