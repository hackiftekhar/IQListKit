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

public typealias IQDiffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<IQSection, IQItem>
@available(iOS 14.0, *)
public typealias IQDiffableDataSourceSectionSnapshot = NSDiffableDataSourceSectionSnapshot<IQItem>

public actor IQList {

    @frozen public enum CellRegistrationType {
        case automatic
        case manual
    }

    // MARK: - Public Properties
    public let listView: IQListView

    @MainActor
    public var clearsSelectionOnDidSelect: Bool = true {
        didSet {
            diffableDataSource.clearsSelectionOnDidSelect = clearsSelectionOnDidSelect
        }
    }

    nonisolated static let elementKindSectionHeader: String = "UICollectionElementKindSectionHeader"
    nonisolated static let elementKindSectionFooter: String = "UICollectionElementKindSectionFooter"
    nonisolated let cellRegisterType: CellRegistrationType

    nonisolated public let defaultRowAnimation: UITableView.RowAnimation

    nonisolated public var removeDuplicatesWhenReloading: Bool {
        get {
            snapshotWrapper.removeDuplicatesWhenReloading
        }
        set {
            snapshotWrapper.removeDuplicatesWhenReloading = newValue
        }
    }

    // MARK: - noItem States
    @MainActor
    private let noItemContainerView: UIView = UIView()

    @MainActor
    public var noItemStateView: IQNoItemStateRepresentable? {
        didSet {
            oldValue?.removeFromSuperview()
            noItemStateViewChanged()
        }
    }

    @MainActor
    private var privateIsLoading: Bool = false

    @MainActor
    public var isLoading: Bool {
        get {  privateIsLoading  }
        set {
            privateIsLoading = newValue
            setIsLoading(newValue)
        }
    }

    @MainActor
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
            guard let self = self else { return }

            noItemContainerView.alpha = showNoItems ? 1.0 : 0.0
            noItemStateView?.setIsLoading(isLoading, haveRecords: haveRecords, animated: animated)
        }, completion: {  [weak self] _ in
            guard let self = self else { return }

            if !showNoItems {
                noItemContainerView.isHidden = true
            }
        })
    }

    // MARK: - Private Properties

    nonisolated internal let reloadQueue: DispatchQueue

    @ReloadActor
    internal let snapshotWrapper: IQDiffableDataSourceSnapshotWrapper = IQDiffableDataSourceSnapshotWrapper()

    @ReloadActor public func batchSnapshot() -> IQDiffableDataSourceSnapshot {
        snapshotWrapper.batchSnapshot
    }

    nonisolated internal let diffableDataSource: IQDiffableDataSource

    // MARK: - Initialization

    /// Initialization
    /// - Parameters:
    ///   - listView: UITableView or UICollectionView
    ///   - delegateDataSource: the delegate and dataSource of the IQListView
    ///   - defaultRowAnimation: default animation when reloading table
    ///   - reloadQueue: queue to reload the data
    @MainActor
    public init(listView: IQListView,
                delegateDataSource: IQListViewDelegateDataSource? = nil,
                defaultRowAnimation: UITableView.RowAnimation = .fade,
                cellRegisterType: CellRegistrationType = .automatic,
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
    @MainActor
    public init(listView: IQListView, delegate: IQListViewDelegate? = nil,
                dataSource: IQListViewDataSource? = nil,
                defaultRowAnimation: UITableView.RowAnimation = .fade,
                cellRegisterType: CellRegistrationType = .automatic,
                reloadQueue: DispatchQueue? = nil) {

        if let tableView = listView as? UITableView {

            self.init(tableView,
                      delegate: delegate, dataSource: dataSource,
                      defaultRowAnimation: defaultRowAnimation,
                      cellRegisterType: cellRegisterType,
                      reloadQueue: reloadQueue)

        } else if let collectionView = listView as? UICollectionView {

            self.init(collectionView,
                      delegate: delegate, dataSource: dataSource,
                      cellRegisterType: cellRegisterType,
                      reloadQueue: reloadQueue)

            let collectionReusableViewIdentifier: String = String(describing: UICollectionReusableView.self)

            collectionView.register(UICollectionReusableView.self,
                                    forSupplementaryViewOfKind: IQList.elementKindSectionHeader,
                                    withReuseIdentifier: collectionReusableViewIdentifier)

            collectionView.register(UICollectionReusableView.self,
                                    forSupplementaryViewOfKind: IQList.elementKindSectionFooter,
                                    withReuseIdentifier: collectionReusableViewIdentifier)

            registerSupplementaryView(type: IQCollectionTitleSupplementaryView.self,
                                      kind: IQList.elementKindSectionHeader, registerType: .class)
            registerSupplementaryView(type: IQCollectionTitleSupplementaryView.self,
                                      kind: IQList.elementKindSectionFooter, registerType: .class)
        } else {
            fatalError("Unable to initializa ListKit")
        }

        noItemStateView = IQNoItemStateView(noItemImage: nil, noItemTitle: nil,
                                            noItemMessage: nil, loadingMessage: nil)
        noItemStateViewChanged()
        updateNoItemStateViewPosition()
    }

    /// Initialize the IQList with the UITableView
    /// - Parameters:
    ///   - tableView: the UITableView
    ///   - delegate: the delegate of the IQListView
    ///   - dataSource: the dataSource of the IQListView
    ///   - defaultRowAnimation: default animation when reloading table
    @MainActor
    private init(_ tableView: UITableView, delegate: IQListViewDelegate?,
                 dataSource: IQListViewDataSource?,
                 defaultRowAnimation: UITableView.RowAnimation,
                 cellRegisterType: CellRegistrationType,
                 reloadQueue: DispatchQueue?) {

        let tableViewDiffableDataSource = IQTableViewDiffableDataSource(tableView: tableView,
                                                                        cellProvider: { (tableView, indexPath, item) in
            let identifier = String(describing: item.type)
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

            if let cell = cell as? IQModelModifiable,
               let model = item.model as? AnyHashable {
                cell.privateSetModel(model)
            } else {
                print("""
                    '\(type(of: cell))' with identifier '\(identifier)' \
                    does not confirm to the '\(IQModelModifiable.self)' protocol
                    """)
            }

            if let cell = cell as? any IQModelableCell {
                delegate?.listView(tableView, modifyCell: cell, at: indexPath)
            }
            return cell
        })

        tableView.delegate = tableViewDiffableDataSource
        tableView.dataSource = tableViewDiffableDataSource
        tableView.prefetchDataSource = tableViewDiffableDataSource
        tableViewDiffableDataSource.defaultRowAnimation = defaultRowAnimation
        tableViewDiffableDataSource.delegate = delegate
        tableViewDiffableDataSource.dataSource = dataSource

        listView = tableView
        diffableDataSource = tableViewDiffableDataSource

        if let reloadQueue = reloadQueue {
            self.reloadQueue = reloadQueue
        } else {
            var controller: UIResponder = tableView
            while !(controller is UIViewController) {
                if let responder = controller.next { controller = responder
                } else { break }
            }
            let reloadQueue: DispatchQueue = DispatchQueue(label: "IQListKit-\(type(of: controller).self)")
            self.reloadQueue = reloadQueue
        }

        self.defaultRowAnimation = defaultRowAnimation
        self.cellRegisterType = cellRegisterType

        tableViewDiffableDataSource.proxyDelegate = self
    }

    /// Initialize the IQList with the UITableView
    /// - Parameters:
    ///   - collectionView: the UICollectionView
    ///   - delegate: the delegate of the IQListView
    ///   - dataSource: the dataSource of the IQListView
    @MainActor
    private init(_ collectionView: UICollectionView,
                 delegate: IQListViewDelegate?,
                 dataSource: IQListViewDataSource?,
                 cellRegisterType: CellRegistrationType,
                 reloadQueue: DispatchQueue?) {

        // swiftlint:disable line_length
        let collectionViewDiffableDataSource = IQCollectionViewDiffableDataSource(collectionView: collectionView,
                                                                                  cellProvider: { (collectionView, indexPath, item) in
            // swiftlint:enable line_length
            let identifier = String(describing: item.type)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            if let cell = cell as? IQModelModifiable,
               let model = item.model as? AnyHashable {
                cell.privateSetModel(model)
            } else {
                print("""
                    '\(type(of: cell))' with identifier '\(identifier)' \
                    does not confirm to the '\(IQModelModifiable.self)' protocol
                    """)
            }

            if let cell = cell as? any IQModelableCell {
                delegate?.listView(collectionView, modifyCell: cell, at: indexPath)
            }
            return cell
        })

        collectionView.delegate = collectionViewDiffableDataSource
        collectionView.dataSource = collectionViewDiffableDataSource
        collectionView.prefetchDataSource = collectionViewDiffableDataSource
        collectionViewDiffableDataSource.delegate = delegate
        collectionViewDiffableDataSource.dataSource = dataSource

        listView = collectionView
        diffableDataSource = collectionViewDiffableDataSource

        if let reloadQueue = reloadQueue {
            self.reloadQueue = reloadQueue
        } else {
            var controller: UIResponder = collectionView
            while !(controller is UIViewController) {
                if let responder = controller.next { controller = responder
                } else { break }
            }
            let reloadQueue: DispatchQueue = DispatchQueue(label: "IQListKit-\(type(of: controller).self)")
            self.reloadQueue = reloadQueue
        }

        self.defaultRowAnimation = .automatic
        self.cellRegisterType = cellRegisterType

        collectionViewDiffableDataSource.proxyDelegate = self
    }
}

@MainActor
extension IQList {

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

    private func noItemStateViewChanged() {

        if let noItemStateView = noItemStateView {
            noItemContainerView.addSubview(noItemStateView)
            if noItemStateView.translatesAutoresizingMaskIntoConstraints {
                noItemStateView.center = CGPoint(x: noItemContainerView.bounds.midX,
                                                 y: noItemContainerView.bounds.midY)
                noItemStateView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin,
                                                    .flexibleLeftMargin, .flexibleRightMargin]
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

@MainActor
extension IQList: IQListViewProxyDelegate {
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        updateNoItemStateViewPosition()
        diffableDataSource.delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}
