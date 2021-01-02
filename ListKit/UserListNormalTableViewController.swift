//
//  UserListNormalTableViewController.swift
//  ListKit
//
//  Created by iftekhar on 02/01/21.
//

import UIKit
import IQListKit

class UserListNormalTableViewController: UITableViewController {

    typealias Item = User
    typealias Cell = UserCell

    private var userItems = [Item]()
    private var defaultCellItems = [IQTableViewCell.Model]()
    private var bookCellItems = [Book]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        tableView.tableFooterView = UIView()
    }
}

extension UserListNormalTableViewController {
    @IBAction func refresh(_ sender: Any) {

        var userItems = [Item]()
        var defaultCellItems = [IQTableViewCell.Model]()
        var bookCellItems = [Book]()

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal

        for index in 1...10000 {
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

        self.tableView.reloadData()
    }
}

extension UserListNormalTableViewController: IQListViewDelegateDataSource {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell else {
            fatalError("Unable to dequeue UserCell")
        }

        cell.model = UserCell.Model(user: self.userItems[indexPath.row], people: nil)
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "UserViewController") as? UserViewController {
            controller.user = self.userItems[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension UserListNormalTableViewController: UserCellDelegate {
    func userCell(_ cell: UserCell, didDelete item: User) {
        if let index = userItems.firstIndex(of: item) {
            userItems.remove(at: index)
            refreshUI()
        }
    }
}
