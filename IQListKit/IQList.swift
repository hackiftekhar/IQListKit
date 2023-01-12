//
//  IQList.swift
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

public final class IQList: NSObject {

    public typealias IQDiffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<IQSection, IQItem>

    // MARK: - Public Properties
    public private(set) var listView: IQListView
    public var clearsSelectionOnDidSelect: Bool = true {
        didSet {
            diffableDataSource.clearsSelectionOnDidSelect = clearsSelectionOnDidSelect
        }
    }

    public var defaultRowAnimation: UITableView.RowAnimation {
        get {
            diffableDataSource.defaultRowAnimation
        }
        set {
            diffableDataSource.defaultRowAnimation = newValue
        }
    }

    public var removeDuplicatesWhenReloading: Bool = false

    // MARK: - noItem States
    public let noItemStateView: IQNoItemStateView = IQNoItemStateView(noItemImage: nil,
                                                                      noItemTitle: nil,
                                                                      noItemMessage: nil,
                                                                      loadingMessage: nil)
    public var noItemImage: UIImage? {
        get {   noItemStateView.noItemImage    }
        set {   noItemStateView.noItemImage = newValue  }
    }
    public var noItemTitle: String? {
        get {   noItemStateView.noItemTitle    }
        set {   noItemStateView.noItemTitle = newValue  }
    }
    public var noItemMessage: String? {
        get {   noItemStateView.noItemMessage    }
        set {   noItemStateView.noItemMessage = newValue  }
    }
    public var loadingMessage: String? {
        get {   noItemStateView.loadingMessage    }
        set {   noItemStateView.loadingMessage = newValue  }
    }
    public func noItemAction(title: String?, target: Any?, action: Selector) {
        noItemStateView.action(title: title, target: target, action: action)
    }

    public var isLoading: Bool {
        get {   noItemStateView.isLoading  }
        set {
            setIsLoading(newValue)
        }
    }

    public func setIsLoading(_ isLoading: Bool,
                             animated: Bool = false) {

        let snapshot: IQDiffableDataSourceSnapshot = self.snapshot()
        let numberOfAllItems = snapshot.numberOfItems

        if numberOfAllItems == 0 {
            listView.insertSubview(noItemStateView, at: 0)
            noItemStateView.translatesAutoresizingMaskIntoConstraints = false

            let inset: UIEdgeInsets = listView.adjustedContentInset
            noItemStateView.leadingAnchor.constraint(equalTo: listView.frameLayoutGuide.leadingAnchor)
                .isActive = true
            noItemStateView.trailingAnchor.constraint(equalTo: listView.frameLayoutGuide.trailingAnchor)
                .isActive = true

            noItemStateView.topAnchor.constraint(equalTo: listView.topAnchor).isActive = true
            let height = listView.frame.height - inset.top - inset.bottom
            noItemStateView.heightAnchor.constraint(equalToConstant: height).isActive = true

            self.noItemStateView.setIsLoading(isLoading, haveRecords: false, animated: animated)
        } else {
            if noItemStateView.superview != nil {
                self.noItemStateView.setIsLoading(isLoading, haveRecords: true, animated: animated)
            }
        }
    }

    public func snapshot() -> IQDiffableDataSourceSnapshot {
        return diffableDataSource.snapshot()
    }

    // MARK: - Private Properties

    internal var registeredCells: [UIView.Type] = [UIView.Type]()
    internal var registeredHeaderFooterViews: [UIView.Type] = [UIView.Type]()

    internal let reloadQueue: DispatchQueue?
    internal var batchSnapshot: IQDiffableDataSourceSnapshot = IQDiffableDataSourceSnapshot()

    internal private(set) var diffableDataSource: IQDiffableDataSource!

    // MARK: - Initialization

    /// Convenience Initialization
    /// - Parameters:
    ///   - listView: UITableView or UICollectionView
    ///   - delegateDataSource: the delegate and dataSource of the IQListView
    ///   - defaultRowAnimation: default animation when reloading table
    ///   - reloadQueue: queue to reload the data
    public convenience init(listView: IQListView,
                            delegateDataSource: IQListViewDelegateDataSource? = nil,
                            defaultRowAnimation: UITableView.RowAnimation = .fade,
                            reloadQueue: DispatchQueue? = nil) {
        self.init(listView: listView,
                  delegate: delegateDataSource, dataSource: delegateDataSource,
                  defaultRowAnimation: defaultRowAnimation, reloadQueue: reloadQueue)
    }

    /// Initialization
    /// - Parameters:
    ///   - listView: UITableView or UICollectionView
    ///   - delegate: the delegate of the IQListView
    ///   - dataSource: the dataSource of the IQListView
    ///   - defaultRowAnimation: default animation when reloading table
    ///   - reloadQueue: queue to reload the data
    public init(listView: IQListView, delegate: IQListViewDelegate? = nil,
                dataSource: IQListViewDataSource? = nil, defaultRowAnimation: UITableView.RowAnimation = .fade,
                reloadQueue: DispatchQueue? = nil) {

        self.listView = listView
        self.reloadQueue = reloadQueue
        super.init()

        if let tableView = listView as? UITableView {

            diffableDataSource = initializeTableViewDataSource(tableView,
                                                               delegate: delegate, dataSource: dataSource,
                                          defaultRowAnimation: defaultRowAnimation)

        } else if let collectionView = listView as? UICollectionView {

            diffableDataSource = initializeCollectionViewDataSource(collectionView,
                                                                    delegate: delegate, dataSource: dataSource)
        } else {
            fatalError("Unable to initializa ListKit")
        }
    }

    /// Initialize the IQList with the UITableView
    /// - Parameters:
    ///   - tableView: the UITableView
    ///   - delegate: the delegate of the IQListView
    ///   - dataSource: the dataSource of the IQListView
    ///   - defaultRowAnimation: default animation when reloading table
    private func initializeTableViewDataSource(_ tableView: UITableView, delegate: IQListViewDelegate?,
                                               dataSource: IQListViewDataSource?,
                                               defaultRowAnimation: UITableView.RowAnimation) -> IQDiffableDataSource {

        typealias CellProvider = (UITableView, IndexPath, IQItem) -> UITableViewCell?

        let provider: CellProvider = { [weak self] (tableView, indexPath, item) in
            let identifier = String(describing: item.type)
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

            if let cell = cell as? IQModelModifiable {
                cell.setModel(item.model)
            } else {
                print("""
                    \(type(of: cell)) with identifier \(identifier) \
                    does not confirm to the \(IQModelModifiable.self) protocol
                    """)
            }

            self?.diffableDataSource.delegate?.listView(tableView, modifyCell: cell, at: indexPath)
            return cell
        }

        let tableViewDiffableDataSource = IQTableViewDiffableDataSource(tableView: tableView,
                                                                        cellProvider: provider)

        tableView.delegate = tableViewDiffableDataSource
        tableView.dataSource = tableViewDiffableDataSource
        tableView.prefetchDataSource = tableViewDiffableDataSource
        tableViewDiffableDataSource.defaultRowAnimation = defaultRowAnimation
        tableViewDiffableDataSource.delegate = delegate
        tableViewDiffableDataSource.dataSource = dataSource

        registerHeaderFooter(type: IQTableViewHeaderFooterView.self, registerType: .class)
        return tableViewDiffableDataSource
    }

    /// Initialize the IQList with the UITableView
    /// - Parameters:
    ///   - collectionView: the UICollectionView
    ///   - delegate: the delegate of the IQListView
    ///   - dataSource: the dataSource of the IQListView
    private func initializeCollectionViewDataSource(_ collectionView: UICollectionView,
                                                    delegate: IQListViewDelegate?,
                                                    dataSource: IQListViewDataSource?) -> IQDiffableDataSource {

        typealias CellProvider = (UICollectionView, IndexPath, IQItem) -> UICollectionViewCell?

        let provider: CellProvider = { [weak self] (collectionView, indexPath, item) in
            let identifier = String(describing: item.type)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            if let cell = cell as? IQModelModifiable {
                cell.setModel(item.model)
            } else {
                print("""
                    \(type(of: cell)) with identifier \(identifier) \
                    does not confirm to the \(IQModelModifiable.self) protocol
                    """)
            }

            self?.diffableDataSource.delegate?.listView(collectionView, modifyCell: cell, at: indexPath)
            return cell
        }

        let collectionViewDiffableDataSource = IQCollectionViewDiffableDataSource(collectionView: collectionView,
                                                                                  cellProvider: provider)

        collectionView.delegate = collectionViewDiffableDataSource
        collectionView.dataSource = collectionViewDiffableDataSource
        collectionView.prefetchDataSource = collectionViewDiffableDataSource
        collectionView.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 22, right: 0)
        collectionViewDiffableDataSource.delegate = delegate
        collectionViewDiffableDataSource.dataSource = dataSource

        registerHeaderFooter(type: UICollectionReusableView.self, registerType: .class)
        registerHeaderFooter(type: IQCollectionViewHeaderFooter.self, registerType: .class)
        return collectionViewDiffableDataSource
    }
}
