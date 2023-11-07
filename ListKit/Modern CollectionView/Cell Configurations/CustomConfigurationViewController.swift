/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A basic compositional layout with cells that use custom configurations.
*/

import UIKit
import IQListKit

@available(iOS 14.0, *)
class CustomConfigurationViewController: UIViewController {

    private enum Section: Hashable {
        case main
    }

    struct Item: Hashable {
        let image: UIImage?
        init(imageName: String) {
            self.image = UIImage(systemName: imageName)
        }
        private let identifier = UUID()

        static let all = Array(repeating: [
            "trash", "folder", "paperplane", "book", "tag", "camera", "pin",
            "lock.shield", "cube.box", "gift", "eyeglasses", "lightbulb"
        ], count: 25).flatMap { $0 }.shuffled().map { Item(imageName: $0) }
    }

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)
    private var collectionView: UICollectionView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Custom Configurations"
        configureHierarchy()
        configureDataSource()
    }
}

@available(iOS 14.0, *)
extension CustomConfigurationViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(44), heightDimension: .estimated(44))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))

        let section = IQCollectionViewSectionLayout.sectionLayout(direction: .horizontal,
                                                                  itemSize: itemSize,
                                                                  groupSize: groupSize,
                                                                  interItemSpacing: .flexible(10))

        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
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

@available(iOS 14.0, *)
extension CustomConfigurationViewController {
    private func configureDataSource() {

        list.clearsSelectionOnDidSelect = false
//        list.registerCell(type: CustomConfigurationCell.self, registerType: .class)

        list.reloadData { builder in

            let section = IQSection(identifier: Section.main)
            builder.append([section])

            builder.append(CustomConfigurationCell.self, models: Item.all)
        }
    }
}

@available(iOS 14.0, *)
extension CustomConfigurationViewController: IQListViewDelegateDataSource {

}
