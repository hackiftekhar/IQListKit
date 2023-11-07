/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A list with inset item content described by compositional layout
*/

import UIKit
import IQListKit

class InsetItemsGridViewController: UIViewController {

    enum Section {
        case main
    }

    var collectionView: UICollectionView! = nil

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Inset Items Grid"
        configureHierarchy()
        configureDataSource()
    }
}

extension InsetItemsGridViewController {
    /// - Tag: Inset
    func createLayout() -> UICollectionViewLayout {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                             heightDimension: .fractionalHeight(1.0))

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(0.2))

        let itemContentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let section = IQCollectionViewSectionLayout.sectionLayout(direction: .horizontal,
                                                                  itemSize: itemSize,
                                                                  itemContentInsets: itemContentInsets,
                                                                  groupSize: groupSize)

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

extension InsetItemsGridViewController {
    func configureDataSource() {

//        list.registerCell(type: TextCell.self, registerType: .class)

        list.reloadData { builder in
            let section = IQSection(identifier: Section.main)
            builder.append([section])

            let items: [TextCell.Model] = Array(0..<94).map { .init(text: "\($0)", cornerRadius: 0, badgeCount: 0) }
            builder.append(TextCell.self, models: items)
        }
    }
}

extension InsetItemsGridViewController: IQListViewDelegateDataSource {
}
