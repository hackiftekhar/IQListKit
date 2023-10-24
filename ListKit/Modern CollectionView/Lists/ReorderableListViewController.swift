/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A list that can be reordered.
*/

import UIKit
import IQListKit

@available(iOS 14.0, *)
class ReorderableListViewController: UIViewController {

    typealias Section = Emoji.Category

    struct Item: Hashable {
        let title: String
        let emoji: Emoji
        init(emoji: Emoji, title: String) {
            self.emoji = emoji
            self.title = title
        }
        private let identifier = UUID()
    }

    enum ReorderingMethod: CustomStringConvertible {
        case finalSnapshot, collectionDifference

        var description: String {
            switch self {
            case .collectionDifference: return "Collection Difference"
            case .finalSnapshot: return "Final Snapshot Items"
            }
        }
    }

    var collectionView: UICollectionView!
    private lazy var list = IQList(listView: collectionView, delegateDataSource: self, defaultRowAnimation: .automatic)
    lazy var backingStore: [Section: [Item]] = { initialBackingStore() }()

    var reorderingMethod: ReorderingMethod = .collectionDifference

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavItem()
        configureHierarchy()
        configureDataSource()
        applySnapshotsFromBackingStore()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = self.collectionView.indexPathsForSelectedItems?.first {
            if let coordinator = self.transitionCoordinator {
                coordinator.animate(alongsideTransition: { _ in
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                }, completion: { (context) in
                    if context.isCancelled {
                        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    }
                })
            } else {
                self.collectionView.deselectItem(at: indexPath, animated: animated)
            }
        }
    }
}

@available(iOS 14.0, *)
extension ReorderableListViewController {

    func configureNavItem() {
        navigationItem.title = "Reorderable List"
        navigationItem.largeTitleDisplayMode = .always

        func createMenu() -> UIMenu {
            let refreshAction = UIAction(title: "Reload backingStore",
                                         image: UIImage(systemName: "arrow.counterclockwise")) { [weak self] _ in
                guard let self = self else { return }
                // update from our source of truth: our backing store.
                // This shows us that the backing store was properly updated from any
                // reordering operation
                self.applySnapshotsFromBackingStore(animated: true)
            }

            let restoreAction = UIAction(title: "Reload initialStore",
                                         image: UIImage(systemName: "arrow.counterclockwise")) { [weak self] _ in
                guard let self = self else { return }
                self.applyInitialBackingStore(animated: true)
            }

            let finalSnapshotAction = UIAction(
                title: String(describing: ReorderingMethod.finalSnapshot),
                image: UIImage(systemName: "function")) { [weak self] action in
                guard let self = self else { return }
                self.reorderingMethod = .finalSnapshot
                if let barButtonItem = action.sender as? UIBarButtonItem {
                    barButtonItem.menu = createMenu()
                }
            }

            let collectionDifferenceAction = UIAction(
                title: String(describing: ReorderingMethod.collectionDifference),
                image: UIImage(systemName: "function")) { [weak self] action in
                guard let self = self else { return }
                self.reorderingMethod = .collectionDifference
                if let barButtonItem = action.sender as? UIBarButtonItem {
                    barButtonItem.menu = createMenu()
                }
            }

            if self.reorderingMethod == .collectionDifference {
                collectionDifferenceAction.state = .on
            } else if self.reorderingMethod == .finalSnapshot {
                finalSnapshotAction.state = .on
            }

            let reorderingMethodMenu = UIMenu(title: "", options: .displayInline,
                                              children: [finalSnapshotAction, collectionDifferenceAction])
            let menu = UIMenu(title: "", children: [refreshAction, restoreAction, reorderingMethodMenu])
            return menu
        }
        let navItem = UIBarButtonItem(image: UIImage(systemName: "gear"), menu: createMenu())
        navigationItem.rightBarButtonItem = navItem
    }

    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }

    func createLayout() -> UICollectionViewLayout {
        return IQCollectionViewLayout.listLayout(appearance: .insetGrouped)
    }
}

@available(iOS 14.0, *)
extension ReorderableListViewController {

    func configureDataSource() {

        list.registerCell(type: ReorderingListCell.self, registerType: .class)

        list.reorderingHandlers?.canReorderItem = { _ in return true }
        list.reorderingHandlers?.didReorder = { [weak self] transaction in
            guard let self = self else { return }

            // method 1: enumerate through the section transactions and update
            //           each section's backing store via the Swift stdlib CollectionDifference API

            if self.reorderingMethod == .collectionDifference {

                for transaction in transaction.sectionTransactions {
                    if let identifier = transaction.sectionIdentifier.identifier as? Section {
                        if let previousItems = self.backingStore[identifier] {
                           let previousItems = previousItems.map { IQItem(ReorderingListCell.self, model: $0) }
                            if let updatedItems = previousItems.applying(transaction.difference) {
                                self.backingStore[identifier] = updatedItems.compactMap({
                                    $0.model as? Item
                                })
                            }
                        }
                    }
                }

            // method 2: use the section transaction's finalSnapshot items as the new updated ordering

            } else if self.reorderingMethod == .finalSnapshot {

                for transaction in transaction.sectionTransactions {
                    if let sectionIdentifier = transaction.sectionIdentifier.identifier as? Section {
                        let items: [Item] = transaction.finalSnapshot.items.compactMap({ $0.model as? Item })
                        self.backingStore[sectionIdentifier] = items
                    }
                }
            }
        }
    }

    func initialBackingStore() -> [Section: [Item]] {
        var allItems = [Section: [Item]]()
        for category in Emoji.Category.allCases.reversed() {
            let items = category.emojis.map { Item(emoji: $0, title: String(describing: category)) }
            allItems[category] = items
        }
        return allItems
    }

    func applyInitialBackingStore(animated: Bool = false) {

        for (section, items) in initialBackingStore() {

            var sectionSnapshot = IQDiffableDataSourceSectionSnapshot()

            let items: [IQItem] = items.map { IQItem(ReorderingListCell.self, model: $0) }
            sectionSnapshot.append(items)

            let section = IQSection(identifier: section)

            list.apply(sectionSnapshot, to: section, animatingDifferences: animated)
        }
    }

    func applySnapshotsFromBackingStore(animated: Bool = false) {

        for (section, items) in backingStore {

            var sectionSnapshot = IQDiffableDataSourceSectionSnapshot()

            let items: [IQItem] = items.map { IQItem(ReorderingListCell.self, model: $0) }
            sectionSnapshot.append(items)

            let section = IQSection(identifier: section)

            list.apply(sectionSnapshot, to: section, animatingDifferences: animated)
        }
    }
}

@available(iOS 14.0, *)
extension ReorderableListViewController: IQListViewDelegateDataSource {

}
