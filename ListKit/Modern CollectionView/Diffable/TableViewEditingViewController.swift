/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Sample demonstrating UITableViewDiffableDataSource using editing, reordering and header/footer titles support
*/

import UIKit
import IQListKit

class TableViewEditingViewController: UIViewController {

    enum Section: Int {
        case visited = 0, bucketList
        func description() -> String {
            switch self {
            case .visited:
                return "Visited"
            case .bucketList:
                return "Bucket List"
            }
        }
        func secondaryDescription() -> String {
            switch self {
            case .visited:
                return "Trips I've made!"
            case .bucketList:
                return "Need to do this before I go!"
            }
        }
    }

    typealias SectionType = Section
    typealias ItemType = MountainsController.Mountain
    let mountainsController = MountainsController()
    let limit = 8
    var bucketList: [MountainsController.Mountain] = []
    var visited: [MountainsController.Mountain] = []

//        // MARK: editing support
//        override func tableView(_ tableView: UITableView,
    // commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//            if editingStyle == .delete {
//                if let identifierToDelete = itemIdentifier(for: indexPath) {
//                    var snapshot = self.snapshot()
//                    snapshot.deleteItems([identifierToDelete])
//                    apply(snapshot)
//                }
//            }
//        }
//    }

    var tableView: UITableView!
    private lazy var list = IQList(listView: tableView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()

        let mountains = mountainsController.filteredMountains(limit: limit)
        bucketList = Array(mountains[0..<limit / 2])
        visited = Array(mountains[limit / 2..<limit])

        configureDataSource()
        configureNavigationItem()
    }
}

extension TableViewEditingViewController {

    func configureHierarchy() {

        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }

    func configureDataSource() {

//        list.registerCell(type: LabelTableCell.self, registerType: .nib)
        reloadDataSource()
    }

    func reloadDataSource() {
        list.reloadData { [visited, bucketList] builder in

            let visitedSection = IQSection(identifier: SectionType.visited, header: SectionType.visited.description())
            let bucketListSection = IQSection(identifier: SectionType.bucketList,
                                              header: SectionType.bucketList.description())

            builder.append([visitedSection, bucketListSection])

            builder.append(LabelTableCell.self, models: visited, section: visitedSection)
            builder.append(LabelTableCell.self, models: bucketList, section: bucketListSection)
        }
    }

    func configureNavigationItem() {
        navigationItem.title = "UITableView: Editing"
        let title: String = tableView.isEditing ? "Done" : "Edit"
        let editingItem = UIBarButtonItem(title: title,
                                          style: .plain, target: self,
                                          action: #selector(toggleEditing))
        navigationItem.rightBarButtonItems = [editingItem]
    }

    @objc
    func toggleEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        configureNavigationItem()
    }
}

extension TableViewEditingViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQListView, canEdit item: IQItem, at indexPath: IndexPath) -> Bool? {
        return true
    }

    func listView(_ listView: IQListView, canMove item: IQItem, at indexPath: IndexPath) -> Bool? {
        return true
    }

    func listView(_ listView: IQListView, move sourceItem: IQItem,
                  at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        guard let sourceSection = Section(rawValue: sourceIndexPath.section),
        let sourceMountain = sourceItem.model as? LabelTableCell.Model,
        let destinationSection = Section(rawValue: destinationIndexPath.section) else { return }

        switch sourceSection {
        case .visited:
            if let index = visited.firstIndex(of: sourceMountain) {
                visited.remove(at: index)
            }
        case .bucketList:
            if let index = bucketList.firstIndex(of: sourceMountain) {
                bucketList.remove(at: index)
            }
        }

        switch destinationSection {
        case .visited:
            visited.insert(sourceMountain, at: destinationIndexPath.row)
        case .bucketList:
            bucketList.insert(sourceMountain, at: destinationIndexPath.row)
        }

//        reloadDataSource()
    }

    func listView(_ listView: IQListView, commit item: IQItem,
                  style: UITableViewCell.EditingStyle, at indexPath: IndexPath) {
        switch style {
        case .none:
            break
        case .delete:
            guard let section = Section(rawValue: indexPath.section),
            let mountain = item.model as? LabelTableCell.Model else { return }

            switch section {
            case .visited:
                if let index = visited.firstIndex(of: mountain) {
                    visited.remove(at: index)
                }
            case .bucketList:
                if let index = bucketList.firstIndex(of: mountain) {
                    bucketList.remove(at: index)
                }
            }

            reloadDataSource()

        case .insert:
            break
        @unknown default:
            break
        }
    }
}
