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

    @available(iOS 14.0, *)
    public typealias IQDiffableDataSourceSectionSnapshot = NSDiffableDataSourceSectionSnapshot<IQItem>

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
    private let noItemContainerView: UIView = UIView()
    public var noItemStateView: IQNoItemStateRepresentable? {
        didSet {
            oldValue?.removeFromSuperview()

            if let noItemStateView = noItemStateView {
                noItemContainerView.addSubview(noItemStateView)
                if noItemStateView.translatesAutoresizingMaskIntoConstraints {
                    noItemStateView.center = CGPoint(x: noItemContainerView.bounds.midX,
                                                     y: noItemContainerView.bounds.midY)
                    noItemStateView.autoresizingMask = [.flexibleTopMargin,
                                                        .flexibleBottomMargin,
                                                        .flexibleLeftMargin,
                                                        .flexibleRightMargin]
                } else {
                    noItemStateView.leadingAnchor.constraint(greaterThanOrEqualTo: noItemContainerView.leadingAnchor,
                                                             constant: 20)
                    .isActive = true
                    noItemStateView.trailingAnchor.constraint(lessThanOrEqualTo: noItemContainerView.trailingAnchor,
                                                              constant: 20)
                    .isActive = true
                    noItemStateView.topAnchor.constraint(greaterThanOrEqualTo: noItemContainerView.topAnchor,
                                                         constant: 20)
                    .isActive = true
                    noItemStateView.bottomAnchor.constraint(lessThanOrEqualTo: noItemContainerView.bottomAnchor,
                                                            constant: 20)
                    .isActive = true
                }
            }
        }
    }
    public var noItemImage: UIImage? {
        get {   noItemStateView?.noItemImage    }
        set {   noItemStateView?.noItemImage = newValue  }
    }
    public var noItemTitle: String? {
        get {   noItemStateView?.noItemTitle    }
        set {   noItemStateView?.noItemTitle = newValue  }
    }
    public var noItemMessage: String? {
        get {   noItemStateView?.noItemMessage    }
        set {   noItemStateView?.noItemMessage = newValue  }
    }
    public var loadingMessage: String? {
        get {   noItemStateView?.loadingMessage    }
        set {   noItemStateView?.loadingMessage = newValue  }
    }
    public func noItemAction(title: String?, target: Any?, action: Selector) {
        noItemStateView?.action(title: title, target: target, action: action)
    }

    private var privateIsLoading: Bool = false
    public var isLoading: Bool {
        get {  privateIsLoading  }
        set {
            privateIsLoading = newValue
            setIsLoading(newValue)
        }
    }

    public func setIsLoading(_ isLoading: Bool,
                             animated: Bool = false) {

        privateIsLoading = isLoading

        let snapshot: IQDiffableDataSourceSnapshot = snapshot()
        let haveRecords: Bool = snapshot.numberOfItems > 0
        let animationDuration = animated ? 0.3 : 0

        let showNoItems = (isLoading || !haveRecords)
        if showNoItems {
            self.noItemContainerView.isHidden = false
        }

        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            self?.noItemContainerView.alpha = showNoItems ? 1.0 : 0.0
            self?.noItemStateView?.setIsLoading(isLoading, haveRecords: haveRecords, animated: animated)
        }, completion: { _ in
            if !showNoItems {
                self.noItemContainerView.isHidden = true
            }
        })
    }

    // MARK: - Private Properties

    internal let reloadQueue: DispatchQueue
    public internal(set) var batchSnapshot: IQDiffableDataSourceSnapshot = IQDiffableDataSourceSnapshot()

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
                            reloadQueue: DispatchQueue = DispatchQueue.main) {
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
                reloadQueue: DispatchQueue = DispatchQueue.main) {

        defer { // This is to call the didSet of noItemStateView
            noItemStateView = IQNoItemStateView(noItemImage: nil,
                                                noItemTitle: nil,
                                                noItemMessage: nil,
                                                loadingMessage: nil)
            updateNoItemStateViewPosition()
        }

        self.listView = listView
        self.reloadQueue = reloadQueue
        super.init()

        if let tableView = listView as? UITableView {

            diffableDataSource = initializeTableViewDataSource(tableView,
                                                               delegate: delegate, dataSource: dataSource,
                                          defaultRowAnimation: defaultRowAnimation)

            registerSupplementaryView(type: IQTableTitleSupplementaryView.self, kind: "", registerType: .class)
            registerSupplementaryView(type: IQTableEmptySupplementaryView.self, kind: "", registerType: .class)

        } else if let collectionView = listView as? UICollectionView {

            diffableDataSource = initializeCollectionViewDataSource(collectionView,
                                                                    delegate: delegate, dataSource: dataSource)

            registerSupplementaryView(type: UICollectionReusableView.self,
                                      kind: UICollectionView.elementKindSectionHeader, registerType: .class)
            registerSupplementaryView(type: UICollectionReusableView.self,
                                      kind: UICollectionView.elementKindSectionFooter, registerType: .class)
            registerSupplementaryView(type: IQCollectionTitleSupplementaryView.self,
                                      kind: UICollectionView.elementKindSectionHeader, registerType: .class)
            registerSupplementaryView(type: IQCollectionTitleSupplementaryView.self,
                                      kind: UICollectionView.elementKindSectionFooter, registerType: .class)
            registerSupplementaryView(type: IQCollectionEmptySupplementaryView.self,
                                      kind: UICollectionView.elementKindSectionHeader, registerType: .class)
            registerSupplementaryView(type: IQCollectionEmptySupplementaryView.self,
                                      kind: UICollectionView.elementKindSectionFooter, registerType: .class)

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
        tableViewDiffableDataSource.proxyDelegate = self
        tableViewDiffableDataSource.delegate = delegate
        tableViewDiffableDataSource.dataSource = dataSource

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
        collectionViewDiffableDataSource.proxyDelegate = self
        collectionViewDiffableDataSource.delegate = delegate
        collectionViewDiffableDataSource.dataSource = dataSource

        return collectionViewDiffableDataSource
    }

    private func updateNoItemStateViewPosition() {
        listView.insertSubview(noItemContainerView, at: 0)
        noItemContainerView.translatesAutoresizingMaskIntoConstraints = false

        let inset: UIEdgeInsets = listView.adjustedContentInset
        noItemContainerView.leadingAnchor.constraint(equalTo: listView.frameLayoutGuide.leadingAnchor)
            .isActive = true
        noItemContainerView.trailingAnchor.constraint(equalTo: listView.frameLayoutGuide.trailingAnchor)
            .isActive = true

        noItemContainerView.topAnchor.constraint(equalTo: listView.topAnchor).isActive = true
        let height = listView.frame.height - inset.top - inset.bottom
        noItemContainerView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}

extension IQList: IQListViewProxyDelegate {
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        updateNoItemStateViewPosition()
        diffableDataSource.delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}
