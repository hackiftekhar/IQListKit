/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Sample showing how we might create a search UI using a diffable data source
*/

import UIKit
import IQListKit

class MountainsViewController: UIViewController {

    let mountainsController = MountainsController()
    let searchBar = UISearchBar(frame: .zero)
    var mountainsCollectionView: UICollectionView!

    private lazy var listWrapper = IQListWrapper(listView: mountainsCollectionView,
                                                 type: LabelCollectionCell.self,
                                                 registerType: .nib, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        configureHierarchy()

        listWrapper.list.noItemStateView?.tintColor = UIColor.darkGray
        listWrapper.list.noItemImage = UIImage(named: "empty")
        listWrapper.list.noItemTitle = "No Results"
        listWrapper.list.noItemMessage = "No mountains found with given name"

        performQuery(with: nil)
    }

    func performQuery(with filter: String?) {
        let mountains = mountainsController.filteredMountains(with: filter).sorted { $0.name < $1.name }
        listWrapper.setModels(mountains, animated: true)
    }
}

extension MountainsViewController {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let columns = contentSize.width > 800 ? 3 : 2
            let spacing = CGFloat(10)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(32))

            let section = IQCollectionViewSectionLayout.sectionLayout(direction: .horizontal,
                                                                      itemSize: itemSize,
                                                                      groupSize: groupSize,
                                                                      gridCount: columns,
                                                                      interItemSpacing: .fixed(spacing))
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            return section
        }
        return layout
    }

    func configureHierarchy() {
        view.backgroundColor = .systemBackground
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        view.addSubview(searchBar)

        let views = ["cv": collectionView, "searchBar": searchBar]
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[cv]|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[searchBar]|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "V:[searchBar]-20-[cv]|", options: [], metrics: nil, views: views))
        constraints.append(searchBar.topAnchor.constraint(
            equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0))
        NSLayoutConstraint.activate(constraints)
        mountainsCollectionView = collectionView

        searchBar.delegate = self
    }
}

extension MountainsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performQuery(with: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension MountainsViewController: IQListViewDelegateDataSource {
}
