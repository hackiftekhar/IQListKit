/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Shows how to use NSCollectionLayoutSupplementaryItems to badge items
*/

import UIKit
import IQListKit

class ItemBadgeSupplementaryViewController: UIViewController {

    nonisolated static let sectionHeaderElementKind = "section-header-element-kind"
    nonisolated static let sectionFooterElementKind = "section-footer-element-kind"
    nonisolated static let badgeElementKind = "badge-element-kind"

    enum Section {
        case main
    }

    struct Model: Hashable {
        let title: String
        let badgeCount: Int

        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }

    var collectionView: UICollectionView! = nil

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Item Badges"
        configureHierarchy()
        configureDataSource()
    }
}

extension ItemBadgeSupplementaryViewController {
    /// - Tag: Badge
    func createLayout() -> UICollectionViewLayout {

        let badgeAnchor = NSCollectionLayoutAnchor(edges: [.top, .trailing], fractionalOffset: CGPoint(x: 0.3, y: -0.3))
        let badgeSize = NSCollectionLayoutSize(widthDimension: .absolute(20),
                                              heightDimension: .absolute(20))
        let badge = NSCollectionLayoutSupplementaryItem(
            layoutSize: badgeSize,
            elementKind: ItemBadgeSupplementaryViewController.badgeElementKind,
            containerAnchor: badgeAnchor)

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                             heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(0.2))

        let itemContentInsets: NSDirectionalEdgeInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)

        let section = IQCollectionViewSectionLayout.sectionLayout(direction: .horizontal,
                                                                  itemSize: itemSize,
                                                                  supplementaryItems: [badge],
                                                                  itemContentInsets: itemContentInsets,
                                                                  groupSize: groupSize)
        section.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)

        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SectionHeadersFootersViewController.sectionHeaderElementKind, alignment: .top)
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SectionHeadersFootersViewController.sectionFooterElementKind, alignment: .bottom)
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]

        let layout = IQCollectionViewLayout.layout(scrollDirection: .vertical,
                                                       section: section)
        return layout
    }
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
}

extension ItemBadgeSupplementaryViewController: IQListViewDelegateDataSource {

    private func configureDataSource() {

//        list.registerCell(type: TextCell.self, registerType: .class)
        list.registerSupplementaryView(type: BadgeSupplementaryView.self,
                                       kind: Self.badgeElementKind, registerType: .class)
        list.registerSupplementaryView(type: HeaderTitleSupplementaryView.self,
                                       kind: Self.sectionHeaderElementKind, registerType: .class)
        list.registerSupplementaryView(type: FooterTitleSupplementaryView.self,
                                       kind: Self.sectionFooterElementKind, registerType: .class)

        list.reloadData { builder in

            let section = IQSection(identifier: Section.main,
                                    headerType: HeaderTitleSupplementaryView.self,
                                    headerModel: Self.sectionHeaderElementKind,
                                    footerType: FooterTitleSupplementaryView.self,
                                    footerModel: Self.sectionFooterElementKind)
            builder.append([section])

            let models: [Model] = (0..<100).map { Model(title: "\($0)", badgeCount: Int.random(in: 0..<3)) }

            let badgeModels: [BadgeSupplementaryView.Model] = models.map { $0.badgeCount }

            let items: [TextCell.Model] = models.map {
                .init(text: $0.title, cornerRadius: 8, badgeCount: $0.badgeCount)
            }
            builder.append(TextCell.self, models: items,
                           supplementaryType: BadgeSupplementaryView.self,
                           supplementaryModels: badgeModels)
        }
    }
}

extension UIColor {
    static var cornflowerBlue: UIColor {
        return UIColor(displayP3Red: 100.0 / 255.0, green: 149.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
    }
}
