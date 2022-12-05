//
//  MountainsViewController.swift
//  ListKit
//
//  Created by Iftekhar on 04/01/21.
//

import UIKit
import IQListKit

struct Mountain: Hashable {
    var name: String

    func contains(_ filter: String) -> Bool {
        guard !filter.isEmpty else {
            return true
        }

        let lowercasedFilter = filter.lowercased()
        return name.lowercased().contains(lowercasedFilter)
    }
}

class MountainsViewController: UIViewController {

    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var collectionView: UICollectionView!

    private lazy var list = IQList(listView: collectionView)

    private let allMountains: [Mountain] = mountainsRawData.components(separatedBy: .newlines).map { line -> Mountain in
        let name = line.components(separatedBy: ",")[0]
        return Mountain(name: name)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        list.noItemImage = UIImage(named: "empty")
        list.noItemTitle = "No Results"
        list.noItemMessage = "No mountains found with given name"

        search(filter: "")
    }

    func search(filter: String) {
        let mountains = allMountains.lazy
            .filter { $0.contains(filter) }
            .sorted { $0.name < $1.name }
        list.performUpdates { _ in
            let section = IQSection(identifier: "mountains")
            list.append([section])

            list.append(LabelCell.self, models: mountains, section: section)
        }
    }
}

extension MountainsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(filter: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
