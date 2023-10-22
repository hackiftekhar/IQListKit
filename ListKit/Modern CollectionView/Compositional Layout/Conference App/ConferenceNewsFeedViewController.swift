/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Sample showing how we might build the news feed UI
*/

import UIKit
import IQListKit

class ConferenceNewsFeedViewController: UIViewController {

    enum Section {
        case main
    }

    let newsController = ConferenceNewsController()

    var collectionView: UICollectionView!
    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Conference News Feed"
        configureHierarchy()
        configureDataSource()
    }
}

extension ConferenceNewsFeedViewController {
    func createLayout() -> UICollectionViewLayout {
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
        let layout = IQCollectionViewLayout.layout(scrollDirection: .vertical, section: section)
        return layout
    }
    func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
}

extension ConferenceNewsFeedViewController {

    private func configureDataSource() {

//        list.registerCell(type: ConferenceNewsFeedCell.self, registerType: .class)

        list.reloadData { [self] in

            let sectionIdentifier = UUID()
            let section = IQSection(identifier: Section.main)
            list.append([section])

            let items: [ConferenceNewsFeedCell.Model] = newsController.items.map {
                .init(section: sectionIdentifier, item: $0, isLastCell: false)
            }
            list.append(ConferenceNewsFeedCell.self, models: items)
        }
    }
}

extension ConferenceNewsFeedViewController: IQListViewDelegateDataSource {
}
