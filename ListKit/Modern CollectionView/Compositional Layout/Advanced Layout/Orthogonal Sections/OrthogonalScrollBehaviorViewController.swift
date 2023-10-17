/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Orthogonal scrolling section behaviors example
*/

import UIKit
import IQListKit

class OrthogonalScrollBehaviorViewController: UIViewController {
    static let headerElementKind = "header-element-kind"

    /// - Tag: OrthogonalBehavior
    enum SectionKind: Int, CaseIterable {
        case continuous, continuousGroupLeadingBoundary, paging, groupPaging, groupPagingCentered, none
        func orthogonalScrollingBehavior() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
            switch self {
            case .none:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.none
            case .continuous:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuous
            case .continuousGroupLeadingBoundary:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
            case .paging:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.paging
            case .groupPaging:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPaging
            case .groupPagingCentered:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
            }
        }
    }

    var collectionView: UICollectionView! = nil

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Orthogonal Section Behaviors"
        configureHierarchy()
        configureDataSource()
    }
}

extension OrthogonalScrollBehaviorViewController {

    //   +-----------------------------------------------------+
    //   | +---------------------------------+  +-----------+  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |     1     |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  +-----------+  |
    //   | |               0                 |                 |
    //   | |                                 |  +-----------+  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |     2     |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | +---------------------------------+  +-----------+  |
    //   +-----------------------------------------------------+

    func createLayout() -> UICollectionViewLayout {

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20

        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let sectionIdentifier = self.list.sectionIdentifiers[sectionIndex]
            guard let sectionKind = sectionIdentifier.identifier as? SectionKind else { return nil }

            let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1.0)))
            leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3)))
            trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0)),
                                                                 subitem: trailingItem,
                                                                 count: 2)

            let orthogonallyScrolls = sectionKind.orthogonalScrollingBehavior() != .none
            let containerGroupFractionalWidth = orthogonallyScrolls ? CGFloat(0.85) : CGFloat(1.0)
            let containerGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(containerGroupFractionalWidth),
                                                  heightDimension: .fractionalHeight(0.4)),
                subitems: [leadingItem, trailingGroup])
            let section = NSCollectionLayoutSection(group: containerGroup)
            section.orthogonalScrollingBehavior = sectionKind.orthogonalScrollingBehavior()

            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(44)),
                elementKind: OrthogonalScrollBehaviorViewController.headerElementKind,
                alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            return section

        }, configuration: config)
        return layout
    }
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
}

extension OrthogonalScrollBehaviorViewController: IQListViewDelegateDataSource {

    private func configureDataSource() {

        list.registerCell(type: TextCell.self, registerType: .class)
        list.registerSupplementaryView(type: TitleSupplementaryView.self, kind: Self.headerElementKind, registerType: .class)

        list.reloadData { [self] in

            var identifierOffset = 0
            let itemsPerSection = 18

            for (sectionIndex, section) in SectionKind.allCases.enumerated() {

                let headerModel = "." + String(describing: section)
                let section = IQSection(identifier: section, headerType: TitleSupplementaryView.self, headerModel: headerModel)
                list.append([section])

                let maxIdentifier = identifierOffset + itemsPerSection

                let numbers = Array(identifierOffset..<maxIdentifier)

                var items: [TextCell.Model] = []
                for (rowIndex, _) in numbers.enumerated() {
                    items.append(.init(text: "\(sectionIndex),\(rowIndex)", cornerRadius: 8.0, badgeCount: nil))
                }

                list.append(TextCell.self, models: items)
                identifierOffset += itemsPerSection
            }
        }
    }
}
