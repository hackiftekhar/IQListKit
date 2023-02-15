/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A simple outline view for the sample app's main UI
*/

import UIKit
import IQListKit

@available(iOS 14.0, *)
class OutlineViewController: UIViewController {

    enum Section {
        case main
    }

    struct OutlineItem: Hashable {
        let title: String
        let subitems: [OutlineItem]
        let outlineViewController: UIViewController.Type?

        init(title: String,
             viewController: UIViewController.Type? = nil,
             subitems: [OutlineItem] = []) {
            self.title = title
            self.subitems = subitems
            self.outlineViewController = viewController
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        private let identifier = UUID()
    }

    var outlineCollectionView: UICollectionView! = nil

    private lazy var list = IQList(listView: outlineCollectionView, delegateDataSource: self)


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Modern Collection Views"
        configureCollectionView()
        configureDataSource()
    }

    private lazy var menuItems: [OutlineItem] = {
        return [
            OutlineItem(title: "Compositional Layout", subitems: [
                OutlineItem(title: "Getting Started", subitems: [
                    OutlineItem(title: "Grid", viewController: GridViewController.self),
                    OutlineItem(title: "Inset Items Grid",
                                viewController: InsetItemsGridViewController.self),
                    OutlineItem(title: "Two-Column Grid", viewController: TwoColumnViewController.self),
                    OutlineItem(title: "Per-Section Layout", subitems: [
                        OutlineItem(title: "Distinct Sections",
                                    viewController: DistinctSectionsViewController.self),
                        OutlineItem(title: "Adaptive Sections",
                                    viewController: AdaptiveSectionsViewController.self)
                        ])
                    ]),
                OutlineItem(title: "Advanced Layouts", subitems: [
                    OutlineItem(title: "Supplementary Views", subitems: [
                        OutlineItem(title: "Item Badges",
                                    viewController: ItemBadgeSupplementaryViewController.self),
                        OutlineItem(title: "Section Headers/Footers",
                                    viewController: SectionHeadersFootersViewController.self),
                        OutlineItem(title: "Pinned Section Headers",
                                    viewController: PinnedSectionHeaderFooterViewController.self)
                        ]),
                    OutlineItem(title: "Section Background Decoration",
                                viewController: SectionDecorationViewController.self),
                    OutlineItem(title: "Nested Groups",
                                viewController: NestedGroupsViewController.self),
                    OutlineItem(title: "Orthogonal Sections", subitems: [
                        OutlineItem(title: "Orthogonal Sections",
                                    viewController: OrthogonalScrollingViewController.self),
                        OutlineItem(title: "Orthogonal Section Behaviors",
                                    viewController: OrthogonalScrollBehaviorViewController.self)
                        ])
                    ]),
                OutlineItem(title: "Conference App", subitems: [
                    OutlineItem(title: "Videos",
                                viewController: ConferenceVideoSessionsViewController.self),
                    OutlineItem(title: "News", viewController: ConferenceNewsFeedViewController.self),
                    OutlineItem(title: "Videos + News", viewController: NewsVideoCombinedViewController.self)
                    ])
            ]),
            OutlineItem(title: "Diffable Data Source", subitems: [
                OutlineItem(title: "Mountains Search", viewController: MountainsViewController.self),
                OutlineItem(title: "Settings: Wi-Fi", viewController: WiFiSettingsViewController.self),
                OutlineItem(title: "Insertion Sort Visualization",
                            viewController: InsertionSortViewController.self),
                OutlineItem(title: "UITableView: Editing",
                            viewController: TableViewEditingViewController.self)
                ]),
            OutlineItem(title: "Lists", subitems: [
                OutlineItem(title: "Simple List", viewController: SimpleListViewController.self),
                OutlineItem(title: "Reorderable List", viewController: ReorderableListViewController.self),
                OutlineItem(title: "List Appearances", viewController: ListAppearancesViewController.self),
                OutlineItem(title: "List with Custom Cells", viewController: CustomCellListViewController.self)
            ]),
            OutlineItem(title: "Outlines", subitems: [
                OutlineItem(title: "Emoji Explorer", viewController: EmojiExplorerViewController.self),
                OutlineItem(title: "Emoji Explorer - List", viewController: EmojiExplorerListViewController.self)
            ]),
            OutlineItem(title: "Cell Configurations", subitems: [
                OutlineItem(title: "Custom Configurations", viewController: CustomConfigurationViewController.self)
            ]),
            OutlineItem(title: "Custom Layout (Layout Editor)", viewController: CustomLayoutViewController.self)
        ]
    }()
}

@available(iOS 14.0, *)
extension OutlineViewController {

    func createLayout() -> UICollectionViewLayout {
        return IQCollectionViewLayout.listLayout(appearance: .sidebar)
    }

    func configureCollectionView() {

        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .systemGroupedBackground
        self.outlineCollectionView = collectionView
    }

    func configureDataSource() {

        list.registerCell(type: OutlineCell.self, registerType: .class)

        var snapshot = IQList.IQDiffableDataSourceSectionSnapshot()

        func addItems(_ items: [IQItem], to parent: IQItem?) {

            snapshot.append(items, to: parent)
            for item in items {

                if let menuItem = item.model as? OutlineItem, !menuItem.subitems.isEmpty {

                    let items = menuItem.subitems.map {
                        IQItem(OutlineCell.self, model: $0)
                    }
                    addItems(items, to: item)
                }
            }
        }

        let items = menuItems.map {
            IQItem(OutlineCell.self, model: $0)
        }

        addItems(items, to: nil)

        list.apply(snapshot, to: IQSection(identifier: Section.main))
    }
}

@available(iOS 14.0, *)
extension OutlineViewController: IQListViewDelegateDataSource {
    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {
        
        if let menuItem = item.model as? OutlineItem, let viewController = menuItem.outlineViewController {
            navigationController?.pushViewController(viewController.init(), animated: true)
        }
    }
}
