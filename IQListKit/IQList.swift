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
import DiffableDataSources

private protocol _TableViewDiffableDataSource where Self: UITableViewDataSource, Self: UITableViewDelegate {
    var delegate: IQListViewDelegate? { get set }
    var dataSource: IQListViewDataSource? { get set }
    var defaultRowAnimation: UITableView.RowAnimation { get set }
    var clearsSelectionOnDidSelect: Bool { get set }
}

@available(iOS 13.0, *)
extension IQTableViewDiffableDataSource: _TableViewDiffableDataSource {}
@available(iOS, deprecated: 13.0)
extension DDSTableViewDiffableDataSource: _TableViewDiffableDataSource {}

private protocol _CollectionViewDiffableDataSource
where Self: UICollectionViewDataSource, Self: UICollectionViewDelegate {
    var delegate: IQListViewDelegate? { get set }
    var dataSource: IQListViewDataSource? { get set }
    var clearsSelectionOnDidSelect: Bool { get set }
}
@available(iOS 13.0, *)
extension IQCollectionViewDiffableDataSource: _CollectionViewDiffableDataSource {}
@available(iOS, deprecated: 13.0)
extension DDSCollectionViewDiffableDataSource: _CollectionViewDiffableDataSource {}

public final class IQList: NSObject {

    // MARK: - Public Properties
    public private(set) var listView: IQListView
    public var clearsSelectionOnDidSelect: Bool = true {
        didSet {
            tableViewDataSource?.clearsSelectionOnDidSelect = clearsSelectionOnDidSelect
            collectionViewDataSource?.clearsSelectionOnDidSelect = clearsSelectionOnDidSelect
        }
    }

    public var removeDuplicatesWhenReloading: Bool = false

    // MARK: - Empty States
    public let emptyStateView: IQEmptyStateView = IQEmptyStateView(image: nil, title: nil, message: nil)
    public var noItemImage: UIImage? {
        get {   emptyStateView.image    }
        set {   emptyStateView.image = newValue  }
    }
    public var noItemTitle: String? {
        get {   emptyStateView.title    }
        set {   emptyStateView.title = newValue  }
    }
    public var noItemMessage: String? {
        get {   emptyStateView.message    }
        set {   emptyStateView.message = newValue  }
    }
    public func noItemAction(title: String?, target: Any?, action: Selector) {
        emptyStateView.action(title: title, target: target, action: action)
    }

    // MARK: - Loading
    /// Will display in the middle if isLoading is true
    public let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)

    private var _isLoading: Bool = false
    public var isLoading: Bool {
        get {   _isLoading  }
        set {
            setIsLoading(newValue)
        }
    }

    public func setIsLoading(_ isLoading: Bool,
                             animated: Bool = false) {
        _isLoading = isLoading

        var numberOfAllItems = 0

        if #available(iOS 13.0, *) {
            let snapshot: NSDiffableDataSourceSnapshot<IQSection, IQItem>?
            if let tvDataSource = tableViewDataSource as? IQTableViewDiffableDataSource {
                snapshot = tvDataSource.snapshot()
            } else if let cvDataSource = collectionViewDataSource as? IQCollectionViewDiffableDataSource {
                snapshot = cvDataSource.snapshot()
            } else {
                snapshot = nil
            }

            if let snapshot = snapshot {
                numberOfAllItems = snapshot.numberOfItems
            }
        } else {
            let snapshot: DiffableDataSourceSnapshot<IQSection, IQItem>?
            if let tvDataSource = tableViewDataSource as? DDSTableViewDiffableDataSource {
                snapshot = tvDataSource.snapshot()
            } else if let cvDataSource = collectionViewDataSource as? DDSCollectionViewDiffableDataSource {
                snapshot = cvDataSource.snapshot()
            } else {
                snapshot = nil
            }

            if let snapshot = snapshot {
                numberOfAllItems = snapshot.numberOfItems
            }
        }

        let animationDuration = animated ? 0.3 : 0
        if numberOfAllItems == 0 {
            isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
            if isLoading {
                emptyStateView.removeFromSuperview()
                listView.insertSubview(loadingIndicator, at: 0)
                loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
                loadingIndicator.centerXAnchor.constraint(equalTo: listView.centerXAnchor).isActive = true
                loadingIndicator.centerYAnchor.constraint(equalTo: listView.centerYAnchor).isActive = true

                UIView.animate(withDuration: animationDuration) { [weak self] in
                    self?.emptyStateView.alpha = 0.0
                }
            } else {
                loadingIndicator.removeFromSuperview()
                listView.insertSubview(emptyStateView, at: 0)
                emptyStateView.translatesAutoresizingMaskIntoConstraints = false

                let inset: UIEdgeInsets

                if #available(iOS 11.0, *) {
                    inset = listView.adjustedContentInset
                    emptyStateView.leadingAnchor.constraint(equalTo: listView.frameLayoutGuide.leadingAnchor)
                        .isActive = true
                    emptyStateView.trailingAnchor.constraint(equalTo: listView.frameLayoutGuide.trailingAnchor)
                        .isActive = true
                } else {
                    inset = listView.contentInset
                    emptyStateView.leadingAnchor.constraint(equalTo: listView.leadingAnchor).isActive = true
                    emptyStateView.trailingAnchor.constraint(equalTo: listView.trailingAnchor).isActive = true
                }

                emptyStateView.topAnchor.constraint(equalTo: listView.topAnchor).isActive = true
                let height = listView.frame.height - inset.top - inset.bottom
                emptyStateView.heightAnchor.constraint(equalToConstant: height).isActive = true

                UIView.animate(withDuration: animationDuration) { [weak self] in
                    self?.emptyStateView.alpha = 1.0
                }
            }
        } else {
            loadingIndicator.stopAnimating()
            if emptyStateView.superview != nil {
                UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                    self?.emptyStateView.alpha = 0.0
                }, completion: { [weak self] success in
                    if success {
                        self?.emptyStateView.removeFromSuperview()
                    }
                })
            }
        }
    }

    @available(iOS 13.0, *)
    public func snapshot() -> NSDiffableDataSourceSnapshot<IQSection, IQItem> {
        if let tableViewDataSource = tableViewDataSource as? IQTableViewDiffableDataSource {
            return tableViewDataSource.snapshot()
        } else if let collectionViewDataSource = collectionViewDataSource as? IQCollectionViewDiffableDataSource {
            return collectionViewDataSource.snapshot()
        } else {
            fatalError("No snapshot found")
        }
    }

    @available(iOS, deprecated: 13.0)
    public func ddsSnapshot() -> DiffableDataSourceSnapshot<IQSection, IQItem> {
        if let tableViewDataSource = tableViewDataSource as? DDSTableViewDiffableDataSource {
            return tableViewDataSource.snapshot()
        } else if let collectionViewDataSource = collectionViewDataSource as? DDSCollectionViewDiffableDataSource {
            return collectionViewDataSource.snapshot()
        } else {
            if #available(iOS 13.0, *) {
                fatalError("Please use snapshot() method for iOS 13.0 and above")
            } else {
                fatalError("No snapshot found")
            }
        }
    }

    // MARK: - Private Properties

    internal var registeredCells: [UIView.Type] = [UIView.Type]()
    internal var registeredHeaderFooterViews: [UIView.Type] = [UIView.Type]()

    /// This tweak is written due to old iOS version compatibility
    private var _privateBatchSnapshot: Any?
    @available(iOS 13.0, *)
    private var batchSnapshot: NSDiffableDataSourceSnapshot<IQSection, IQItem>? {
        get {
            return _privateBatchSnapshot as? NSDiffableDataSourceSnapshot
        }
        set {
            _privateBatchSnapshot = newValue
        }
    }

    @available(iOS, deprecated: 13.0)
    private var ddsBatchSnapshot: DiffableDataSourceSnapshot<IQSection, IQItem>?
    private var tableViewDataSource: _TableViewDiffableDataSource?
    private var collectionViewDataSource: _CollectionViewDiffableDataSource?

    // MARK: - Initialization

    /// Convenience Initialization
    /// - Parameters:
    ///   - listView: UITableView or UICollectionView
    ///   - delegateDataSource: the delegate and dataSource of the IQListView
    ///   - defaultRowAnimation: default animation when reloading table
    public convenience init(listView: IQListView,
                            delegateDataSource: IQListViewDelegateDataSource? = nil,
                            defaultRowAnimation: UITableView.RowAnimation = .fade) {
        self.init(listView: listView,
                  delegate: delegateDataSource, dataSource: delegateDataSource,
                  defaultRowAnimation: defaultRowAnimation)
    }

    /// Initialization
    /// - Parameters:
    ///   - listView: UITableView or UICollectionView
    ///   - delegate: the delegate of the IQListView
    ///   - dataSource: the dataSource of the IQListView
    ///   - defaultRowAnimation: default animation when reloading table
    public init(listView: IQListView, delegate: IQListViewDelegate? = nil,
                dataSource: IQListViewDataSource? = nil, defaultRowAnimation: UITableView.RowAnimation = .fade) {

        self.listView = listView
        super.init()

        if let tableView = listView as? UITableView {

            initializeTableViewDataSource(tableView, delegate: delegate, dataSource: dataSource,
                                          defaultRowAnimation: defaultRowAnimation)

        } else if let collectionView = listView as? UICollectionView {

            initializeCollectionViewDataSource(collectionView, delegate: delegate, dataSource: dataSource)
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
                                               defaultRowAnimation: UITableView.RowAnimation) {

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

            self?.tableViewDataSource?.delegate?.listView(tableView, modifyCell: cell, at: indexPath)
            return cell
        }

        if #available(iOS 13.0, *) {
            let tableDataSource = IQTableViewDiffableDataSource(tableView: tableView,
                                                                cellProvider: provider)
            tableViewDataSource = tableDataSource
        } else {
            let tableDataSource = DDSTableViewDiffableDataSource(tableView: tableView,
                                                                 cellProvider: provider)
            tableViewDataSource = tableDataSource
        }

        tableView.delegate = tableViewDataSource
        tableView.dataSource = tableViewDataSource
        tableViewDataSource?.defaultRowAnimation = defaultRowAnimation
        tableViewDataSource?.delegate = delegate
        tableViewDataSource?.dataSource = dataSource

        registerHeaderFooter(type: IQTableViewHeaderFooterView.self, registerType: .class)
    }

    /// Initialize the IQList with the UITableView
    /// - Parameters:
    ///   - collectionView: the UICollectionView
    ///   - delegate: the delegate of the IQListView
    ///   - dataSource: the dataSource of the IQListView
    private func initializeCollectionViewDataSource(_ collectionView: UICollectionView,
                                                    delegate: IQListViewDelegate?,
                                                    dataSource: IQListViewDataSource?) {

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

            self?.collectionViewDataSource?.delegate?.listView(collectionView, modifyCell: cell, at: indexPath)
            return cell
        }

        if #available(iOS 13.0, *) {
            let collectionDataSource = IQCollectionViewDiffableDataSource(collectionView: collectionView,
                                                                          cellProvider: provider)
            collectionViewDataSource = collectionDataSource
        } else {
            let collectionDataSource = DDSCollectionViewDiffableDataSource(collectionView: collectionView,
                                                                           cellProvider: provider)
            collectionViewDataSource = collectionDataSource
        }

        collectionViewDataSource?.delegate = delegate
        collectionViewDataSource?.dataSource = dataSource
        collectionView.delegate = collectionViewDataSource
        collectionView.dataSource = collectionViewDataSource
        collectionView.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 22, right: 0)

        registerHeaderFooter(type: UICollectionReusableView.self, registerType: .class)
        registerHeaderFooter(type: IQCollectionViewHeaderFooter.self, registerType: .class)
    }
}

// MARK: - Update the list
/// Note that all these methods can also be used in a background threads since they all
/// methods deal with the models, not any UI elements.
/// NSDiffableDataSourceSnapshot.apply is also background thread safe
// swiftlint:disable file_length
public extension IQList {

    /// Append the models to the given section
    /// This method can also be used in background thread
    /// - Parameters:
    ///   - type: Type of the IQModelableCell
    ///   - models: the models of type IQModelableCell.Model
    ///   - section: section in which we'll be adding the models
    // swiftlint:disable cyclomatic_complexity
    func append<T: IQModelableCell>(_ type: T.Type, models: [T.Model], section: IQSection? = nil) {

        if registeredCells.contains(where: { $0 == type}) == false {
            registerCell(type: type, registerType: .default)
        }

        var items: [IQItem] = []
        for model in models {
            let item = IQItem(type, model: model)
            items.append(item)
        }

        if removeDuplicatesWhenReloading {
            if #available(iOS 13.0, *) {
                if let existingItems = batchSnapshot?.itemIdentifiers {
                    let result = items.removeDuplicate(existingElements: existingItems)
                    items = result.unique
                    if !result.duplicate.isEmpty {
                        let duplicate = result.duplicate.compactMap { $0.model }
                        print("IQListKit: Ignoring \(duplicate.count) duplicate elements.\n\(duplicate))")
                    }
                }
            } else {
                if let existingItems = ddsBatchSnapshot?.itemIdentifiers {
                    let result = items.removeDuplicate(existingElements: existingItems)
                    items = result.unique
                    if !result.duplicate.isEmpty {
                        let duplicate = result.duplicate.compactMap { $0.model }
                        print("IQListKit: Ignoring \(duplicate.count) duplicate elements.\n\(duplicate))")
                    }
                }
            }
        }

        if #available(iOS 13.0, *) {
            if let section = section {
                batchSnapshot?.appendItems(items, toSection: section)
            } else {
                batchSnapshot?.appendItems(items)
            }
        } else {
            if let section = section {
                ddsBatchSnapshot?.appendItems(items, toSection: section)
            } else {
                ddsBatchSnapshot?.appendItems(items)
            }
        }
    }

    /// Appends a section to the list
    /// This method can also be used in background thread
    /// - Parameter section: section which needs to be added to the list
    func append(_ section: IQSection) {
        if #available(iOS 13.0, *) {
            batchSnapshot?.appendSections([section])
        } else {
            ddsBatchSnapshot?.appendSections([section])
        }
    }

    /// Performs the list reload
    /// - Parameters:
    ///   - updates: update block which will be called to generate the snapshot
    ///   - animatingDifferences: If true then animates the differences otherwise do not animate.
    ///   - completion: the completion block will be called after reloading the list
    func performUpdates(_ updates: () -> Void, animatingDifferences: Bool = true,
                        completion: (() -> Void)? = nil) {
        if #available(iOS 13.0, *) {
            batchSnapshot = NSDiffableDataSourceSnapshot<IQSection, IQItem>()
        } else {
            ddsBatchSnapshot = DiffableDataSourceSnapshot<IQSection, IQItem>()
        }

        updates()

        if #available(iOS 13.0, *) {
            if let snapshot = batchSnapshot {
                batchSnapshot = nil

                if #available(iOS 15.0, *), !animatingDifferences {
                    if let dataSource = tableViewDataSource as? IQTableViewDiffableDataSource {
                        dataSource.applySnapshotUsingReloadData(snapshot, completion: completion)
                    } else if let dataSource = collectionViewDataSource as? IQCollectionViewDiffableDataSource {
                        dataSource.applySnapshotUsingReloadData(snapshot, completion: completion)
                    }
                } else {
                    if let dataSource = tableViewDataSource as? IQTableViewDiffableDataSource {
                        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
                    } else if let dataSource = collectionViewDataSource as? IQCollectionViewDiffableDataSource {
                        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
                    }
                }

                let isLoading = self.isLoading

                if Thread.isMainThread {
                    self.setIsLoading(isLoading, animated: animatingDifferences)    /// Updating the backgroundView
                } else {
                    OperationQueue.main.addOperation {
                        self.setIsLoading(isLoading,
                                          animated: animatingDifferences)    /// Updating the backgroundView on main thread
                    }
                }
            }
        } else {
            if let snapshot = ddsBatchSnapshot {
                ddsBatchSnapshot = nil

                if let dataSource = tableViewDataSource as? DDSTableViewDiffableDataSource {
                    dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
                } else if let dataSource = collectionViewDataSource as? DDSCollectionViewDiffableDataSource {
                    dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
                }

                let isLoading = self.isLoading

                if Thread.isMainThread {
                    self.setIsLoading(isLoading, animated: animatingDifferences)    /// Updating the backgroundView
                } else {
                    OperationQueue.main.addOperation {
                        self.setIsLoading(isLoading,
                                          animated: animatingDifferences)    /// Updating the backgroundView on main thread
                    }
                }
            }
        }
    }
}
