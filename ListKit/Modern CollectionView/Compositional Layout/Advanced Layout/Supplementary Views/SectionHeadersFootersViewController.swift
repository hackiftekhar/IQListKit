/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Section headers and footers example
*/

import UIKit
import IQListKit

class SectionHeadersFootersViewController: UIViewController {

    static let sectionHeaderElementKind = "section-header-element-kind"
    static let sectionFooterElementKind = "section-footer-element-kind"

    var collectionView: UICollectionView! = nil

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Section Headers/Footers"
        configureHierarchy()
        configureDataSource()
    }
}

extension SectionHeadersFootersViewController {
    /// - Tag: HeaderFooter
    func createLayout() -> UICollectionViewLayout {

        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SectionHeadersFootersViewController.sectionHeaderElementKind, alignment: .top)
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SectionHeadersFootersViewController.sectionFooterElementKind, alignment: .bottom)

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(44))

        let itemContentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let section = IQCollectionViewSectionLayout.sectionLayout(direction: .horizontal,
                                                                  itemSize: itemSize,
                                                                  itemContentInsets: itemContentInsets,
                                                                  groupSize: groupSize,
                                                                  gridCount: 2,
                                                                  interItemSpacing: .fixed(10))
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
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

extension SectionHeadersFootersViewController: IQListViewDelegateDataSource {

    private func configureDataSource() {

//        list.registerCell(type: ListCell.self, registerType: .class)
        list.registerSupplementaryView(type: HeaderTitleSupplementaryView.self,
                                       kind: Self.sectionHeaderElementKind, registerType: .class)
        list.registerSupplementaryView(type: FooterTitleSupplementaryView.self,
                                       kind: Self.sectionFooterElementKind, registerType: .class)

        list.reloadData { [self] in

            let sections = Array(0..<5)
            let itemsPerSection = 5
            var itemOffset = 0

            for sectionIndex in sections {
                let headerModel: String = "\(Self.sectionHeaderElementKind) for section \(sectionIndex)"
                let footerModel: String = "\(Self.sectionFooterElementKind) for section \(sectionIndex)"
                let section = IQSection(identifier: sectionIndex,
                                        headerType: HeaderTitleSupplementaryView.self, headerModel: headerModel,
                                        footerType: FooterTitleSupplementaryView.self, footerModel: footerModel)
                list.append([section])

                itemOffset += itemsPerSection
                let numbers = Array(itemOffset..<itemOffset + itemsPerSection)

                var items: [ListCell.Model] = []
                for rowIndex in numbers.indices {
                    items.append(.init(text: "\(sectionIndex),\(rowIndex)"))
                }

                list.append(ListCell.self, models: items)
            }
        }
    }
}
