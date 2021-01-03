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

    private var users = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        tableView.tableFooterView = UIView()
    }
}

extension UserListNormalTableViewController {
    @IBAction func refresh(_ sender: Any) {

        var users = [Item]()

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal

        for index in 1...100 {
            if let string = numberFormatter.string(from: NSNumber.init(value: index)) {
                users.append(.init(name: string))
            }
        }

        self.users = users

        refreshUI()
    }

    @IBAction func empty(_ sender: UIBarButtonItem) {
        self.users = []
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
        return self.users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell else {
            fatalError("Unable to dequeue UserCell")
        }

        cell.model = users[indexPath.row]
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "UserViewController") as? UserViewController {
            controller.user = users[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension UserListNormalTableViewController: UserCellDelegate {
    func userCell(_ cell: UserCell, didDelete item: User) {
        if let index = users.firstIndex(of: item) {
            users.remove(at: index)
            refreshUI()
        }
    }
}
