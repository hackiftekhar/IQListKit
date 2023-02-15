/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Section background decoration view example
*/

import UIKit
import IQListKit

class SectionDecorationViewController: UIViewController {

    static let sectionBackgroundDecorationElementKind = "section-background-element-kind"

    var collectionView: UICollectionView! = nil

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Section Background Decoration View"
        configureHierarchy()
        configureDataSource()
    }
}

extension SectionDecorationViewController {
    /// - Tag: Background
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(44))

        let section = IQCollectionViewSectionLayout.sectionLayout(direction: .horizontal,
                                                                  itemSize: itemSize,
                                                                  groupSize: groupSize)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(
            elementKind: SectionDecorationViewController.sectionBackgroundDecorationElementKind)
        sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        section.decorationItems = [sectionBackgroundDecoration]

        let layout = IQCollectionViewLayout.layout(scrollDirection: .vertical, section: section)
        layout.register(
            SectionBackgroundDecorationView.self,
            forDecorationViewOfKind: SectionDecorationViewController.sectionBackgroundDecorationElementKind)
        return layout
    }
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
}

extension SectionDecorationViewController {

    private func configureDataSource() {

        list.registerCell(type: ListCell.self, registerType: .class)

        list.reloadData {

            let itemsPerSection = 5
            let sections = Array(0..<5)
            var itemOffset = 0

            for (sectionIndex, sectionName) in sections.enumerated() {
                let section = IQSection(identifier: sectionName)
                list.append([section])

                let numbers = Array(itemOffset..<itemOffset + itemsPerSection)

                var items: [ListCell.Model] = []
                for (rowIndex, number) in numbers.enumerated() {
                    items.append(.init(text: "\(sectionIndex),\(rowIndex)"))
                }

                items[items.count - 1].isLastCell = true

                list.append(ListCell.self, models: items)
                itemOffset += itemsPerSection
            }
        }
    }
}

extension SectionDecorationViewController: IQListViewDelegateDataSource {
}
