/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A two column grid described by compositional layout
*/

import UIKit
import IQListKit

class TwoColumnViewController: UIViewController {

    enum Section {
        case main
    }

    var collectionView: UICollectionView! = nil

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Two-Column Grid"
        configureHierarchy()
        configureDataSource()
    }
}

extension TwoColumnViewController {
    /// - Tag: TwoColumn
    func createLayout() -> UICollectionViewLayout {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(44))

        let section = IQCollectionViewSectionLayout.sectionLayout(direction: .horizontal,
                                                                  itemSize: itemSize,
                                                                  groupSize: groupSize,
                                                                  gridCount: 2,
                                                                  interItemSpacing: .fixed(10))
        section.interGroupSpacing = 10
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

extension TwoColumnViewController {
    func configureDataSource() {

//        list.registerCell(type: TextCell.self, registerType: .class)

        list.reloadData { [list] in
            let section = IQSection(identifier: Section.main)
            list.append([section])

            let items: [TextCell.Model] = Array(0..<94).map { .init(text: "\($0)", cornerRadius: 0, badgeCount: 0) }
            list.append(TextCell.self, models: items)
        }
    }
}

extension TwoColumnViewController: IQListViewDelegateDataSource {
}
