//
//  NewsVideoCombinedViewController.swift
//  ListKit
//
//  Created by Iftekhar on 2/8/23.
//

import UIKit
import IQListKit

class NewsVideoCombinedViewController: UIViewController {

    enum Section: Hashable {
        case video(collection: ConferenceVideoController.VideoCollection)
        case news(identifier: AnyHashable)
        case list(identifier: AnyHashable)
    }

    let videosController = ConferenceVideoController()
    let newsController = ConferenceNewsController()

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

extension NewsVideoCombinedViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let sectionIdentifier = self.list.sectionIdentifiers[sectionIndex]
            guard let section = sectionIdentifier.identifier as? Section else { return nil }

            switch section {
            case .video(let collection):

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
                section.orthogonalScrollingBehavior = collection.orthogonalScrollBehaviour
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

            case .news:
                let estimatedHeight = CGFloat(100)
                let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(estimatedHeight))

                let section = IQCollectionViewSectionLayout.sectionLayout(direction: .horizontal,
                                                                          itemSize: layoutSize,
                                                                          groupSize: layoutSize,
                                                                          gridCount: 1,
                                                                          interItemSpacing: .fixed(10))

                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                section.interGroupSpacing = 10
                return section
            case .list:
                if #available(iOS 14.0, *) {
                    return IQCollectionViewSectionLayout.listSectionLayout(appearance: .plain,
                                                                           layoutEnvironment: layoutEnvironment)
                } else {
                    return nil
                }
            }
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

extension NewsVideoCombinedViewController: IQListViewDelegateDataSource {

    private func configureDataSource() {

//        if #available(iOS 14.0, *) {
//            list.registerCell(type: SimpleListCell.self, registerType: .class)
//        }
//        list.registerCell(type: ConferenceVideoCell.self, registerType: .class)
//        list.registerCell(type: ConferenceNewsFeedCell.self, registerType: .class)
//        list.registerSupplementaryView(type: TitleSupplementaryView.self,
//                                       kind: Self.titleElementKind, registerType: .class)

        list.reloadData { [self] in

            let itemsPerSection = 5
            var itemOffset = 0

            videosController.collections.forEach { collection in

                let videoSection = IQSection(identifier: Section.video(collection: collection),
                                             headerType: TitleSupplementaryView.self,
                                             headerModel: collection.title)
                list.append([videoSection])
                list.append(ConferenceVideoCell.self, models: collection.videos)

                // Add List
                if #available(iOS 14.0, *) {
                    let sectionIdentifier = UUID()
                    let section = IQSection(identifier: Section.list(identifier: sectionIdentifier))
                    list.append([section])

                    let numbers = Array(itemOffset..<itemOffset + itemsPerSection)
                    itemOffset += itemsPerSection

                    let items: [SimpleListCell.Model] = numbers.map { .init(section: sectionIdentifier, text: "\($0)") }
                    list.append(SimpleListCell.self, models: items)
                }

                // Add news
                do {
                    let sectionIdentifier = UUID()
                    let section = IQSection(identifier: Section.news(identifier: sectionIdentifier))
                    list.append([section])

                    let items: [ConferenceNewsFeedCell.Model] = newsController.items.map {
                        .init(section: sectionIdentifier, item: $0, isLastCell: false)
                    }
                    list.append(ConferenceNewsFeedCell.self, models: items)
                }
            }
        }
    }
}
