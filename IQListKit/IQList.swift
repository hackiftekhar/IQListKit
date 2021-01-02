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
}

@available(iOS 13.0, *)
extension IQTableViewDiffableDataSource: _TableViewDiffableDataSource {}
@available(iOS, deprecated: 13.0)
extension DDSTableViewDiffableDataSource: _TableViewDiffableDataSource {}

private protocol _CollectionViewDiffableDataSource
where Self: UICollectionViewDataSource, Self: UICollectionViewDelegate {
    var delegate: IQListViewDelegate? { get set }
    var dataSource: IQListViewDataSource? { get set }
}
@available(iOS 13.0, *)
extension IQCollectionViewDiffableDataSource: _CollectionViewDiffableDataSource {}
@available(iOS, deprecated: 13.0)
extension DDSCollectionViewDiffableDataSource: _CollectionViewDiffableDataSource {}

public class IQList: NSObject {

    // MARK: - Public Properties

    public private(set) var listView: IQLisView?

    // MARK: - Empty States

    public let emptyStateView = IQEmptyStateView(image: nil, title: nil, message: nil)
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

    //Will display in the middle if isLoading is true
    public let loadingIndicator = UIActivityIndicatorView(style: .gray)

    public var isLoading = false {
        didSet {

            var numberOfAllItems = 0

            if #available(iOS 13.0, *) {
                let snapshot: NSDiffableDataSourceSnapshot<IQSection, IQItem>?
                if let tableViewDataSource = tableViewDataSource as? IQTableViewDiffableDataSource {
                    snapshot = tableViewDataSource.snapshot()
                } else if let collectionViewDataSource = collectionViewDataSource as? IQCollectionViewDiffableDataSource {
                    snapshot = collectionViewDataSource.snapshot()
                } else {
                    snapshot = nil
                }

                if let snapshot = snapshot {
                    numberOfAllItems = snapshot.numberOfItems
                }
            } else {
                let snapshot: DiffableDataSourceSnapshot<IQSection, IQItem>?
                if let tableViewDataSource = tableViewDataSource as? DDSTableViewDiffableDataSource {
                    snapshot = tableViewDataSource.snapshot()
                } else if let collectionViewDataSource = collectionViewDataSource as? DDSCollectionViewDiffableDataSource {
                    snapshot = collectionViewDataSource.snapshot()
                } else {
                    snapshot = nil
                }

                if let snapshot = snapshot {
                    numberOfAllItems = snapshot.numberOfItems
                }
            }

            if numberOfAllItems == 0 {
                isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
                if isLoading {
                    listView?.backgroundView = loadingIndicator
                    listView?.bounces = true
                    UIView.animate(withDuration: 0.3) { [weak self] in
                        self?.emptyStateView.alpha = 0.0
                    }
                } else {
                    listView?.backgroundView = emptyStateView
                    listView?.bounces = false
                    UIView.animate(withDuration: 0.3) { [weak self] in
                        self?.emptyStateView.alpha = 1.0
                    }
                }
            } else {
                loadingIndicator.stopAnimating()
                listView?.bounces = true
                if listView?.backgroundView == emptyStateView {
                    UIView.animate(withDuration: 0.3, animations: { [weak self] in
                        self?.emptyStateView.alpha = 0.0
                    }, completion: { [weak self] success in
                        if success {
                            self?.listView?.backgroundView = nil
                        }
                    })
                } else {
                    listView?.backgroundView = nil
                }
            }
        }
    }

    // MARK: - Private Properties

    private var registeredCells = [UIView.Type]()
    private var registeredHeaderFooterViews = [UIView.Type]()

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

    public convenience init(listView: IQLisView? = nil,
                            delegateDataSource: IQListViewDelegateDataSource? = nil,
                            defaultRowAnimation: UITableView.RowAnimation = .fade) {
        self.init(listView: listView,
                  delegate: delegateDataSource, dataSource: delegateDataSource,
                  defaultRowAnimation: defaultRowAnimation)
    }

    public init(listView: IQLisView? = nil, delegate: IQListViewDelegate? = nil,
                dataSource: IQListViewDataSource? = nil, defaultRowAnimation: UITableView.RowAnimation = .fade) {

        self.listView = listView
        super.init()

        if let tableView = listView as? UITableView {

            let cellProvider: ((UITableView, IndexPath, IQItem) -> UITableViewCell?) = { [weak self] (tbv, idxp, item) in
                let identifier = String(describing: item.type)
                let cell = tbv.dequeueReusableCell(withIdentifier: identifier, for: idxp)

                if let cell = cell as? IQModelModifiable {
                    cell.setModel(item.model)
                } else {
                    print("""
                        \(type(of: cell)) with identifier \(identifier) \
                        does not confirm to the \(IQModelModifiable.self) protocol
                        """)
                }

                self?.tableViewDataSource?.delegate?.listView(tbv, modifyCell: cell, at: idxp)
                return cell
            }

            if #available(iOS 13.0, *) {
                let tableDataSource = IQTableViewDiffableDataSource(tableView: tableView,
                                                                    cellProvider: cellProvider)
                tableViewDataSource = tableDataSource
            } else {
                let tableDataSource = DDSTableViewDiffableDataSource(tableView: tableView,
                                                                     cellProvider: cellProvider)
                tableViewDataSource = tableDataSource
            }

            tableView.delegate = tableViewDataSource
            tableView.dataSource = tableViewDataSource
            tableViewDataSource?.defaultRowAnimation = defaultRowAnimation
            tableViewDataSource?.delegate = delegate
            tableViewDataSource?.dataSource = dataSource

            registerHeaderFooter(type: IQTableViewHeaderFooterView.self)

        } else if let collectionView = listView as? UICollectionView {

            let cellProvider: ((UICollectionView, IndexPath, IQItem) -> UICollectionViewCell?) = { [weak self] (clv, idxp, item) in
                let identifier = String(describing: item.type)
                let cell = clv.dequeueReusableCell(withReuseIdentifier: identifier, for: idxp)
                if let cell = cell as? IQModelModifiable {
                    cell.setModel(item.model)
                } else {
                    print("""
                        \(type(of: cell)) with identifier \(identifier) \
                        does not confirm to the \(IQModelModifiable.self) protocol
                        """)
                }

                self?.collectionViewDataSource?.delegate?.listView(clv, modifyCell: cell, at: idxp)
                return cell
            }

            if #available(iOS 13.0, *) {
                let collectionDataSource = IQCollectionViewDiffableDataSource(collectionView: collectionView,
                                                                              cellProvider: cellProvider)
                collectionViewDataSource = collectionDataSource
            } else {
                let collectionDataSource = DDSCollectionViewDiffableDataSource(collectionView: collectionView,
                                                                               cellProvider: cellProvider)
                collectionViewDataSource = collectionDataSource
            }

            collectionViewDataSource?.delegate = delegate
            collectionViewDataSource?.dataSource = dataSource
            collectionView.delegate = collectionViewDataSource
            collectionView.dataSource = collectionViewDataSource
            collectionView.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 22, right: 0)

            registerHeaderFooter(type: IQCollectionViewHeaderFooter.self)
        }
    }
}

// MARK: - Manual cell and header/footer registration

public extension IQList {

    enum RegisterType {
        case `default`
        case nib
        case `class`
        case storyboard
    }

    func registerCell<T: IQModelableCell>(type: T.Type, bundle: Bundle? = .main,
                                          registerType: RegisterType = .default) {

        guard registeredCells.contains(where: { $0 == type}) == false else {
            return
        }

        func internalRegisterCell() {
            let identifier = String(describing: type)

            if registerType == .default, let tableView = listView as? UITableView {
                //Validate if the cell is configured in storyboard
                if tableView.dequeueReusableCell(withIdentifier: identifier) != nil {
                    registeredCells.append(type)
                    return
                }
            }

            if registerType == .storyboard {
                registeredCells.append(type)
            } else if (registerType == .default || registerType == .nib),
               bundle?.path(forResource: identifier, ofType: "nib") != nil {
                let nib = UINib(nibName: identifier, bundle: bundle)
                if let tableView = listView as? UITableView {
                    registeredCells.append(type)
                    tableView.register(nib, forCellReuseIdentifier: identifier)
                } else if let collectionView = listView as? UICollectionView {
                    registeredCells.append(type)
                    collectionView.register(nib, forCellWithReuseIdentifier: identifier)
                }
            } else if registerType == .default || registerType == .class {
                if let tableView = listView as? UITableView {
                    registeredCells.append(type)
                    tableView.register(type.self, forCellReuseIdentifier: identifier)
                } else if let collectionView = listView as? UICollectionView {
                    registeredCells.append(type)
                    collectionView.register(type.self, forCellWithReuseIdentifier: identifier)
                }
            }
        }

        if Thread.isMainThread {
            internalRegisterCell()
        } else {
            DispatchQueue.main.sync {
                internalRegisterCell()
            }
        }
    }

    func registerHeaderFooter<T: UIView>(type: T.Type, bundle: Bundle? = .main) {

        guard registeredHeaderFooterViews.contains(where: { $0 == type}) == false else {
            return
        }

        func internalRegisterHeaderFooter() {
            let identifier = String(describing: type)

            if bundle?.path(forResource: identifier, ofType: "nib") != nil {
                let nib = UINib(nibName: identifier, bundle: bundle)
                if let tableView = listView as? UITableView {
                    registeredHeaderFooterViews.append(type)
                    tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
                } else if let collectionView = listView as? UICollectionView {
                    registeredHeaderFooterViews.append(type)
                    collectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                            withReuseIdentifier: identifier)
                    collectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                            withReuseIdentifier: identifier)
                }
            } else {
                if let tableView = listView as? UITableView {
                    registeredHeaderFooterViews.append(type)
                    tableView.register(type.self, forHeaderFooterViewReuseIdentifier: identifier)
                } else if let collectionView = listView as? UICollectionView {
                    registeredHeaderFooterViews.append(type)
                    collectionView.register(type.self,
                                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                            withReuseIdentifier: identifier)
                    collectionView.register(type.self,
                                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                            withReuseIdentifier: identifier)
                }
            }
        }

        if Thread.isMainThread {
            internalRegisterHeaderFooter()
        } else {
            DispatchQueue.main.sync {
                internalRegisterHeaderFooter()
            }
        }
    }
}

// MARK: - Update the list
/// Note that all these methods can also be used in a background threads since they all
/// methods deal with the models, not any UI elements.
/// NSDiffableDataSourceSnapshot.apply is also background thread safe
public extension IQList {

    //This method can also be used in background thread
    func append<T: IQModelableCell>(_ type: T.Type, models: [T.Model?], section: IQSection? = nil) {

        if registeredCells.contains(where: { $0 == type}) == false {
            registerCell(type: type)
        }

        var items = [IQItem]()
        for model in models {
            let item = IQItem(type, model: model)
            items.append(item)
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

    //This method can also be used in background thread
    func append(_ section: IQSection) {
        if #available(iOS 13.0, *) {
            batchSnapshot?.appendSections([section])
        } else {
            ddsBatchSnapshot?.appendSections([section])
        }
    }

    //This method can also be used in background thread
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

                if let dataSource = tableViewDataSource as? IQTableViewDiffableDataSource {
                    dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
                } else if let dataSource = collectionViewDataSource as? IQCollectionViewDiffableDataSource {
                    dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
                }

                let isLoading = self.isLoading

                if Thread.isMainThread {
                    self.isLoading = isLoading  //Updating the backgroundView
                } else {
                    OperationQueue.main.addOperation {
                        self.isLoading = isLoading  //Updating the backgroundView on main thread
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
                    self.isLoading = isLoading  //Updating the backgroundView
                } else {
                    OperationQueue.main.addOperation {
                        self.isLoading = isLoading  //Updating the backgroundView on main thread
                    }
                }
            }
        }
    }
}
