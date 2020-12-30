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
    public let loadingIndicator = UIActivityIndicatorView(style: .large)

    public var isLoading = false {
        didSet {

            var numberOfAllItems = 0

            let snapshot: NSDiffableDataSourceSnapshot<IQSection, IQItem>?
            if let tableSnapshot = tableViewDataSource?.snapshot() {
                snapshot = tableSnapshot
            } else if let collectionSnapshot = collectionViewDataSource?.snapshot() {
                snapshot = collectionSnapshot
            } else {
                snapshot = nil
            }

            if let snapshot = snapshot {
                for section in snapshot.sectionIdentifiers {
                    numberOfAllItems += snapshot.numberOfItems(inSection: section)
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
    private var batchSnapshot: NSDiffableDataSourceSnapshot<IQSection, IQItem>?

    private var tableViewDataSource: IQTableViewDiffableDataSource?
    private var collectionViewDataSource: IQCollectionViewDiffableDataSource?

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

            tableViewDataSource = IQTableViewDiffableDataSource(tableView: tableView,
                                                                cellProvider: { [weak self] (tbv, idxp, item)
                                                                    -> UITableViewCell? in
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
            })

            tableViewDataSource?.defaultRowAnimation = defaultRowAnimation
            tableViewDataSource?.delegate = delegate
            tableViewDataSource?.dataSource = dataSource
            tableView.delegate = tableViewDataSource
            tableView.dataSource = tableViewDataSource

            registerHeaderFooter(type: IQTableViewHeaderFooterView.self)

        } else if let collectionView = listView as? UICollectionView {

            collectionViewDataSource = IQCollectionViewDiffableDataSource(collectionView: collectionView,
                                                                          cellProvider: { [weak self] (clv, idxp, item)
                                                                            -> UICollectionViewCell? in
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
            })

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
    func append<T: IQModelableCell>(_ type: T.Type, model: T.Model?, section: IQSection? = nil) {

        if registeredCells.contains(where: { $0 == type}) == false {
            registerCell(type: type)
        }

        let item = IQItem(type, model: model)

        if let section = section {
            batchSnapshot?.appendItems([item], toSection: section)
        } else {
            batchSnapshot?.appendItems([item])
        }
    }

    //This method can also be used in background thread
    func append(_ section: IQSection) {
        batchSnapshot?.appendSections([section])
    }

    //This method can also be used in background thread
    func performUpdates(_ updates: () -> Void, animatingDifferences: Bool = true,
                        completion: (() -> Void)? = nil) {
        batchSnapshot = NSDiffableDataSourceSnapshot()

        updates()

        if let snapshot = batchSnapshot {
            batchSnapshot = nil

            if let dataSource = tableViewDataSource {
                dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
            } else if let dataSource = collectionViewDataSource {
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
