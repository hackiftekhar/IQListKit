/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Sample showing how we might build the videos sessions UI
*/

import UIKit
import IQListKit

class ConferenceVideoSessionsViewController: UIViewController {

    let videosController = ConferenceVideoController()
    var collectionView: UICollectionView! = nil
    static let titleElementKind = "title-element-kind"

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Conference Videos"
        configureHierarchy()
        configureDataSource()
    }
}

extension ConferenceVideoSessionsViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (_: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
            -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            // if we have the space, adapt and go 2-up + peeking 3rd item
            let groupFractionalWidth = CGFloat(layoutEnvironment.container.effectiveContentSize.width > 500 ?
                                               0.425 : 0.8)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                                   heightDimension: .absolute(250))

            let section = IQCollectionViewSectionLayout.sectionLayout(direction: .horizontal,
                                                                      itemSize: itemSize,
                                                                      groupSize: groupSize)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

            let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(44))
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: titleSize,
                elementKind: ConferenceVideoSessionsViewController.titleElementKind,
                alignment: .top)
            section.boundarySupplementaryItems = [titleSupplementary]
            return section
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20

        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        return layout
    }

    func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

extension ConferenceVideoSessionsViewController: IQListViewDelegateDataSource {

    private func configureDataSource() {

//        list.registerCell(type: ConferenceVideoCell.self, registerType: .class)
        list.registerSupplementaryView(type: TitleSupplementaryView.self,
                                       kind: Self.titleElementKind, registerType: .class)

        list.reloadData { [self] in
            videosController.collections.forEach {
                let section = IQSection(identifier: $0, headerType: TitleSupplementaryView.self, headerModel: $0.title)
                list.append([section])
                list.append(ConferenceVideoCell.self, models: $0.videos)
            }
        }
    }
}
