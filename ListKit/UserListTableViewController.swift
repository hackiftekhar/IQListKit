//
//  ViewController.swift
//  ListKit
//
//  Created by Iftekhar on 28/12/20.
//

import UIKit
import IQListKit

class UserListTableViewController: UITableViewController {

    typealias Item = User
    typealias Cell = UserCell

    private var users = [Item]()
    private var defaultCellItems = [IQTableViewCell.Model]()
    private var books = [Book]()

    private var list: IQList!
//    private lazy var list = IQList(listView: tableView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        list = IQList(listView: tableView, delegateDataSource: self)

        list.noItemImage = UIImage(named: "empty")
        list.noItemTitle = "No Items"
        list.noItemMessage = "Nothing to display here."
        list.noItemAction(title: "Reload", target: self, action: #selector(refresh(_:)))

        tableView.tableFooterView = UIView()
        refreshUI(animated: false)
    }
}

extension UserListTableViewController {
    @IBAction func refresh(_ sender: Any) {

        var users = [Item]()
        var defaultCellItems = [IQTableViewCell.Model]()
        var books = [Book]()

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal

        for index in 1...5 {
            if let string = numberFormatter.string(from: NSNumber.init(value: index)) {
                users.append(.init(name: string))
                defaultCellItems.append(.init(text: string, detail: "Loaded using Class"))
                books.append(.init(name: string))
            }
        }

        self.users = users
        self.defaultCellItems = defaultCellItems
        self.books = books

        refreshUI()
    }

    @IBAction func empty(_ sender: UIBarButtonItem) {
        self.users = []
        self.defaultCellItems = []
        self.books = []
        refreshUI()
    }

    func refreshUI(animated: Bool = true) {

        list.performUpdates({

            let section1 = IQSection(identifier: "firstSection")
            list.append(section1)

            for index in 0..<users.count {
                let user = users[index]
                let defaultCellItem = defaultCellItems[index]
                let book = books[index]

                list.append(Cell.self, models: [user], section: section1)
                list.append(IQTableViewCell.self, models: [defaultCellItem], section: section1)
                list.append(BookCell.self, models: [book], section: section1)
            }

        }, animatingDifferences: animated, completion: nil)
    }
}

extension UserListTableViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQListView, modifyCell cell: IQListCell, at indexPath: IndexPath) {
        if let cell = cell as? Cell {
            cell.delegate = self
        }
    }

    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {
        if let model = item.model as? Cell.Model {
            if let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "UserViewController") as? UserViewController {
                controller.user = model
//                controller.user = model
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension UserListTableViewController: UserCellDelegate {
    func userCell(_ cell: UserCell, didDelete item: User) {
        if let index = users.firstIndex(of: item) {
            users.remove(at: index)
            refreshUI()
        }
    }
}
