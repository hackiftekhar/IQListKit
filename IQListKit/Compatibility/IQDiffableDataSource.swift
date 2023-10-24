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

@MainActor
internal protocol IQDiffableDataSource where Self: UIScrollViewDelegate {

    @MainActor var registeredSupplementaryViews: [String: [any IQModelableSupplementaryView.Type]] { get set }

    @MainActor var proxyDelegate: IQListViewProxyDelegate? { get set }
    @MainActor var delegate: IQListViewDelegate? { get set }
    @MainActor var dataSource: IQListViewDataSource? { get set }
    @MainActor var clearsSelectionOnDidSelect: Bool { get set }
    @MainActor var defaultRowAnimation: UITableView.RowAnimation { get set }

    nonisolated func snapshot() -> IQDiffableDataSourceSnapshot

    @MainActor func itemIdentifier(for indexPath: IndexPath) -> IQItem?
    @MainActor func indexPath(for itemIdentifier: IQItem) -> IndexPath?

    @available(iOS 15.0, tvOS 15.0, *)
    nonisolated
    func applySnapshotUsingReloadData(_ snapshot: IQDiffableDataSourceSnapshot,
                                      completion: (() -> Void)?)

    nonisolated
    func apply(_ snapshot: IQDiffableDataSourceSnapshot,
               animatingDifferences: Bool,
               completion: (() -> Void)?)

    // For UICollectionView only
    @available(iOS 14.0, *)
    nonisolated
    func apply(_ snapshot: IQDiffableDataSourceSectionSnapshot, to section: IQSection,
               animatingDifferences: Bool,
               completion: (() -> Void)?)

    @available(iOS 14.0, *)
    nonisolated
    func snapshot(for section: IQSection) -> IQDiffableDataSourceSectionSnapshot
}

@MainActor
extension IQCollectionViewDiffableDataSource: IQDiffableDataSource {

    var defaultRowAnimation: UITableView.RowAnimation {
        get {
            return .automatic
        }
        set {
            print("defaultRowAnimation '\(newValue)' is not supported in UICollectionView")
            // Not supported
        }
    }
}

@MainActor
extension IQTableViewDiffableDataSource: IQDiffableDataSource {
    @available(iOS 14.0, *)
    nonisolated
    func apply(_ snapshot: IQDiffableDataSourceSectionSnapshot, to section: IQSection,
               animatingDifferences: Bool, completion: (() -> Void)?) {
        // doesn't have any effect
        fatalError("Section snapshot isn't supported for UITableView")
    }

    @available(iOS 14.0, *)
    nonisolated
    func snapshot(for section: IQSection) -> IQDiffableDataSourceSectionSnapshot {
        // doesn't have any effect
        fatalError("Section snapshot isn't supported for UITableView")
    }
}
