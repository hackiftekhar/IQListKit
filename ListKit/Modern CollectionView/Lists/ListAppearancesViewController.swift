/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A list that can cycle through the available list appearances.
*/

import UIKit
import IQListKit

@available(iOS 14.0, *)
class ListAppearancesViewController: UIViewController {

    struct Item: Hashable {
        let title: String?
        private let identifier = UUID()
    }

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)
    private var collectionView: UICollectionView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "List Appearances"
        configureHierarchy()
        configureDataSource()
        updateBarButtonItem()
    }

    private var appearance = UICollectionLayoutListConfiguration.Appearance.plain

    @objc
    private func changeListAppearance() {
        switch appearance {
        case .plain:
            appearance = .sidebarPlain
        case .sidebarPlain:
            appearance = .sidebar
        case .sidebar:
            appearance = .grouped
        case .grouped:
            appearance = .insetGrouped
        case .insetGrouped:
            appearance = .plain
        default:
            break
        }
        let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first

        let snapshot = list.snapshot()
        list.apply(snapshot, animatingDifferences: false)
        collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: [])
        updateBarButtonItem()
    }

    private func updateBarButtonItem() {
        let title: String?
        switch appearance {
        case .plain: title = "Plain"
        case .sidebarPlain: title = "Sidebar Plain"
        case .sidebar: title = "Sidebar"
        case .grouped: title = "Grouped"
        case .insetGrouped: title = "Inset Grouped"
        default:    title = ""
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain,
                                                            target: self,
                                                            action: #selector(changeListAppearance))
    }
}

@available(iOS 14.0, *)
extension ListAppearancesViewController {
    /// - Tag: ListAppearances
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [unowned self] _, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: self.appearance)
            config.headerMode = .firstItemInSection
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
}

@available(iOS 14.0, *)
extension ListAppearancesViewController {
    private func configureDataSource() {

        list.registerCell(type: ListAppearanceHeaderCell.self, registerType: .class)
        list.registerCell(type: ListAppearanceItemCell.self, registerType: .class)

        // initial data
        var sectionSnapshot = IQDiffableDataSourceSnapshot()

        let sectionNumbers = Array(0..<5)

        let sections: [IQSection] = sectionNumbers.map { IQSection(identifier: $0) }
        sectionSnapshot.appendSections(sections)
        list.apply(sectionSnapshot, animatingDifferences: false)

        for section in sectionNumbers {
            var sectionSnapshot = IQDiffableDataSourceSectionSnapshot()

            let headerItem = Item(title: "Section \(section)")
            let item = IQItem(ListAppearanceHeaderCell.self, model: headerItem)
            sectionSnapshot.append([item])

            let childItems = Array(0..<3).map { Item(title: "Item \($0)") }
            let listItems = childItems.map { IQItem(ListAppearanceItemCell.self,
                                                    model: .init(item: $0, appearance: appearance)) }
            sectionSnapshot.append(listItems, to: item)

            sectionSnapshot.expand([item])

            let aSection = IQSection(identifier: section)
            list.apply(sectionSnapshot, to: aSection)
        }
    }
}

@available(iOS 14.0, *)
extension ListAppearancesViewController: IQListViewDelegateDataSource {

}
