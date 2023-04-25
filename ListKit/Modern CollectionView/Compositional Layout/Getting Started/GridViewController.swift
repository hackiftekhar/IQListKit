/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A basic grid described by compositional layout
*/

import UIKit
import IQListKit

class GridViewController: UIViewController {

    enum Section {
        case main
    }

    var collectionView: UICollectionView! = nil

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Grid"
        configureHierarchy()
        configureDataSource()
    }
}

extension GridViewController {

    /// - Tag: Grid
    private func createLayout() -> UICollectionViewLayout {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                             heightDimension: .fractionalHeight(1.0))

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(0.2))

        let section = IQCollectionViewSectionLayout.sectionLayout(direction: .horizontal,
                                                                  itemSize: itemSize, groupSize: groupSize)

        let layout = IQCollectionViewLayout.layout(scrollDirection: .vertical,
                                                       section: section)
        return layout
    }
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
}

extension GridViewController {
    private func configureDataSource() {

        list.registerCell(type: TextCell.self, registerType: .class)

        list.reloadData {
            let section = IQSection(identifier: Section.main)
            list.append([section])

            let items: [TextCell.Model] = Array(0..<94).map { .init(text: "\($0)", cornerRadius: 0, badgeCount: 0) }
            list.append(TextCell.self, models: items)
        }
    }
}

extension GridViewController: IQListViewDelegateDataSource {
}
