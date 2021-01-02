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

    private var userItems = [Item]()
    private var defaultCellItems = [IQTableViewCell.Model]()
    private var bookCellItems = [Book]()

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
//        refreshUI(animated: false)
    }
}

extension UserListTableViewController {
    @IBAction func refresh(_ sender: Any) {

        var userItems = [Item]()
        var defaultCellItems = [IQTableViewCell.Model]()
        var bookCellItems = [Book]()

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal

        for index in 1...1000 {
            if let string = numberFormatter.string(from: NSNumber.init(value: index)) {
                userItems.append(.init(name: string))
                defaultCellItems.append(.init(text: string, detail: "Loaded using Class"))
                bookCellItems.append(.init(name: string))
            }
        }

        self.userItems = userItems
        self.defaultCellItems = defaultCellItems
        self.bookCellItems = bookCellItems

        refreshUI()
    }

    @IBAction func empty(_ sender: UIBarButtonItem) {
        self.userItems = []
        self.defaultCellItems = []
        self.bookCellItems = []
        refreshUI()
    }

    func refreshUI(animated: Bool = true) {

        list.performUpdates({

            let section1 = IQSection(identifier: "firstSection")
            list.append(section1)

            for index in 0..<userItems.count {
                let userItem = userItems[index]
                let defaultCellItem = defaultCellItems[index]
                let bookCellItem = bookCellItems[index]

                list.append(Cell.self, models: [Cell.Model(user: userItem, people: nil)], section: section1)

                list.append(IQTableViewCell.self, models: [defaultCellItem], section: section1)

                list.append(BookCell.self, models: [bookCellItem], section: section1)
            }

        }, animatingDifferences: animated, completion: nil)
    }
}

extension UserListTableViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQLisView, modifyCell cell: IQListCell, at indexPath: IndexPath) {
        if let cell = cell as? Cell {
            cell.delegate = self
        }
    }

    func listView(_ listView: IQLisView, didSelect item: IQItem, at indexPath: IndexPath) {
        if let model = item.model as? Cell.Model {
            if let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "UserViewController") as? UserViewController {
                controller.user = model.user
//                controller.user = model
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension UserListTableViewController: UserCellDelegate {
    func userCell(_ cell: UserCell, didDelete item: User) {
        if let index = userItems.firstIndex(of: item) {
            userItems.remove(at: index)
            refreshUI()
        }
    }
}
