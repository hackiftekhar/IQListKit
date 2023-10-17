/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A collection view that uses a different layout for each section
*/

import UIKit
import IQListKit

@available(iOS 14.0, *)
class EmojiExplorerViewController: UIViewController {

    enum Section: Int, Hashable, CaseIterable, CustomStringConvertible {
        case recents, outline, list

        var description: String {
            switch self {
            case .recents: return "Recents"
            case .outline: return "Outline"
            case .list: return "List"
            }
        }
    }

    struct Item: Hashable {
        let title: String?
        let emoji: Emoji?
        let hasChildren: Bool
        init(emoji: Emoji? = nil, title: String? = nil, hasChildren: Bool = false) {
            self.emoji = emoji
            self.title = title
            self.hasChildren = hasChildren
        }
        private let identifier = UUID()
    }

    var starredEmojis = Set<Item>()

    var collectionView: UICollectionView!
    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavItem()
        configureHierarchy()
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = self.collectionView.indexPathsForSelectedItems?.first {
            if let coordinator = self.transitionCoordinator {
                coordinator.animate(alongsideTransition: { _ in
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                }) { (context) in
                    if context.isCancelled {
                        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    }
                }
            } else {
                self.collectionView.deselectItem(at: indexPath, animated: animated)
            }
        }
    }
}

@available(iOS 14.0, *)
extension EmojiExplorerViewController {

    func configureNavItem() {
        navigationItem.title = "Emoji Explorer"
        navigationItem.largeTitleDisplayMode = .always
    }

    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }

    /// - Tag: CreateFullLayout
    func createLayout() -> UICollectionViewLayout {

        let sectionProvider = { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let sectionIdentifier = self?.list.sectionIdentifiers[sectionIndex]
            guard let sectionKind = sectionIdentifier?.identifier as? Section else { return nil }

            switch sectionKind {
            case .recents:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let itemContentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.28), heightDimension: .fractionalWidth(0.2))

                let section = IQCollectionViewSectionLayout.sectionLayout(direction: .horizontal,
                                                                          itemSize: itemSize,
                                                                          itemContentInsets: itemContentInsets,
                                                                          groupSize: groupSize)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                return section
            case .outline:
                let section = IQCollectionViewSectionLayout.listSectionLayout(appearance: .sidebar, layoutEnvironment: layoutEnvironment)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
                return section
            case .list:
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.leadingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
                    guard let self = self else { return nil }
                    guard let item = self.list.itemIdentifier(for: indexPath), let model = item.model as? ListCell.Model else { return nil }
                    return self.leadingSwipeActionConfigurationForListCellItem(model.item)
                }
                let section: NSCollectionLayoutSection = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
                return section
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

@available(iOS 14.0, *)
extension EmojiExplorerViewController {

    func leadingSwipeActionConfigurationForListCellItem(_ item: Item) -> UISwipeActionsConfiguration? {
        let isStarred = self.starredEmojis.contains(item)
        let starAction = UIContextualAction(style: .normal, title: nil) {
            [weak self] (_, _, completion) in
            guard let self = self else {
                completion(false)
                return
            }

            // Don't check again for the starred state. We promised in the UI what this action will do.
            // If the starred state has changed by now, we do nothing, as the set will not change.
            if isStarred {
                self.starredEmojis.remove(item)
            } else {
                self.starredEmojis.insert(item)
            }

            // Reconfigure the cell of this item
            // Make sure we get the current index path of the item.
            if let currentIndexPath = self.list.indexPath(of: ListCell.self, where: { $0.item == item}) {
                if let cell = self.collectionView.cellForItem(at: currentIndexPath) as? UICollectionViewListCell {
                    UIView.animate(withDuration: 0.2) {

                        var accessories = [UICellAccessory.disclosureIndicator()]
                        if isStarred {
                            let star = UIImageView(image: UIImage(systemName: "star.fill"))
                            accessories.append(.customView(configuration: .init(customView: star, placement: .trailing())))
                        }
                        cell.accessories = accessories
                    }
                }
            }

            completion(true)
        }
        starAction.image = UIImage(systemName: isStarred ? "star.slash" : "star.fill")
        starAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [starAction])
    }

    class RecentCell: UICollectionViewListCell, IQModelableCell {
        var model: Emoji? {
            didSet {
                guard let model = model else { return }
                var content = UIListContentConfiguration.cell()
                content.text = model.text
                content.textProperties.font = .boldSystemFont(ofSize: 38)
                content.textProperties.alignment = .center
                content.directionalLayoutMargins = .zero
                contentConfiguration = content
                var background = UIBackgroundConfiguration.listPlainCell()
                background.cornerRadius = 8
                background.strokeColor = .systemGray3
                background.strokeWidth = 1.0 / traitCollection.displayScale
                backgroundConfiguration = background
            }
        }
    }

    class OutlineHeaderCell: UICollectionViewListCell, IQModelableCell {
        var model: String? {
            didSet {
                guard let model = model else { return }
                var content = defaultContentConfiguration()
                content.text = model
                contentConfiguration = content
                accessories = [.outlineDisclosure(options: .init(style: .header))]
            }
        }
    }

    class OutlineEmojiCell: UICollectionViewListCell, IQModelableCell {
        var model: Emoji? {
            didSet {
                guard let model = model else { return }
                var content = defaultContentConfiguration()
                content.text = model.text
                content.secondaryText = model.title
                contentConfiguration = content
                accessories = [.disclosureIndicator()]
            }
        }
    }

    class ListCell: UICollectionViewListCell, IQModelableCell {
        struct Model: Hashable {
            let item: Item
            let isStarred: Bool
        }

        var model: Model? {
            didSet {
                guard let model = model, let emoji = model.item.emoji else { return }
                var content = UIListContentConfiguration.valueCell()
                content.text = emoji.text
                content.secondaryText = String(describing: emoji.category)
                contentConfiguration = content

                var accessories = [UICellAccessory.disclosureIndicator()]
                if model.isStarred {
                    let star = UIImageView(image: UIImage(systemName: "star.fill"))
                    accessories.append(.customView(configuration: .init(customView: star, placement: .trailing())))
                }
                self.accessories = accessories
            }
        }
    }

    /// - Tag: DequeueCells
    func configureDataSource() {

        list.registerCell(type: RecentCell.self, registerType: .class)
        list.registerCell(type: OutlineHeaderCell.self, registerType: .class)
        list.registerCell(type: OutlineEmojiCell.self, registerType: .class)
        list.registerCell(type: ListCell.self, registerType: .class)

        // create registrations up front, then choose the appropriate one to use in the cell provider

        list.reloadData({ [self] in
            let sections: [IQSection] = Section.allCases.map { IQSection(identifier: $0) }
            list.append(sections)
        }, completion: {

            // recents (orthogonal scroller)
            if let section = self.list.sectionIdentifier(where: { ($0.identifier as? Section) == Section.recents }) {
                let recentEmojis = Emoji.Category.recents.emojis
                let recentListItems: [IQItem] = recentEmojis.map { IQItem(RecentCell.self, model: $0) }
                var recentsSnapshot = IQList.IQDiffableDataSourceSectionSnapshot()
                recentsSnapshot.append(recentListItems)
                self.list.apply(recentsSnapshot, to: section, animatingDifferences: false)
            }

            // list of all + outlines

            var allSnapshot = IQList.IQDiffableDataSourceSectionSnapshot()
            var outlineSnapshot = IQList.IQDiffableDataSourceSectionSnapshot()

            for category in Emoji.Category.allCases where category != .recents {
                // append to the "all items" snapshot
                let allSnapshotItems = category.emojis.map { Item(emoji: $0) }
                let allSnapshotListItems: [IQItem] = allSnapshotItems.map { IQItem(ListCell.self, model: .init(item: $0, isStarred: false)) }
                allSnapshot.append(allSnapshotListItems)

                // setup our parent/child relations
                let rootItem = Item(title: String(describing: category), hasChildren: true)
                let rootListItem: IQItem = IQItem(OutlineHeaderCell.self, model: rootItem.title ?? "")
                outlineSnapshot.append([rootListItem])
                let outlineListItems: [IQItem] =  category.emojis.map { IQItem(OutlineEmojiCell.self, model: $0) }
                outlineSnapshot.append(outlineListItems, to: rootListItem)
            }

            if let section = self.list.sectionIdentifier(where: { ($0.identifier as? Section) == Section.list }) {
                self.list.apply(allSnapshot, to: section, animatingDifferences: false)
            }

            if let section = self.list.sectionIdentifier(where: { ($0.identifier as? Section) == Section.outline }) {
                self.list.apply(outlineSnapshot, to: section, animatingDifferences: false)
            }

            // prepopulate starred emojis

            let allItems = allSnapshot.items.compactMap({ $0.model as? Item })
            for _ in 0..<5 {
                if let item = allItems.randomElement() {
                    self.starredEmojis.insert(item)
                }
            }
        })
    }
}

@available(iOS 14.0, *)
extension EmojiExplorerViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {
        if let model = item.model as? RecentCell.Model {
            let detailViewController = EmojiDetailViewController(with: model)
            self.navigationController?.pushViewController(detailViewController, animated: true)
        } else if let model = item.model as? ListCell.Model, let emoji = model.item.emoji {
            let detailViewController = EmojiDetailViewController(with: emoji)
            self.navigationController?.pushViewController(detailViewController, animated: true)
        } else if let model = item.model as? OutlineEmojiCell.Model {
            let detailViewController = EmojiDetailViewController(with: model)
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
}
