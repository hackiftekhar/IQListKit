//
//  UserListTableViewController.swift
//  ListKit
//
//  Created by Iftekhar on 28/12/20.
//

import UIKit
import IQListKit

class UserListTableViewController: UITableViewController {

    @IBOutlet private var headerView: UIView!
    @IBOutlet private var footerView: UIView!
    @IBOutlet private var customNoItemsView: CustomNoItemView!

    private var users: [User] = []
    private var users2: [User] = []

    private lazy var reloadQueue: DispatchQueue = DispatchQueue(label: "\(Self.self)")
    private lazy var list = IQList(listView: tableView, delegateDataSource: self, reloadQueue: reloadQueue)

    override func viewDidLoad() {
        super.viewDidLoad()

        list.removeDuplicatesWhenReloading = true
//        list.noItemStateView = customNoItemsView
        list.noItemStateView?.tintColor = UIColor.darkGray
        list.noItemImage = UIImage(named: "empty")
        list.noItemTitle = "No Users"
        list.noItemMessage = "No users to display here."
        list.noItemAction(title: "Reload", target: self, action: #selector(refresh(_:)))

//        tableView.tableFooterView = UIView()
        refreshUI(animated: false)
    }
}

extension UserListTableViewController {

    @IBAction func refresh(_ sender: Any) {

        var allUsers: [User] = []
        allUsers.append(User(id: 1, name: "Sid Kumar", email: "sid.kumar1@gmail.com"))
        allUsers.append(User(id: 2, name: "Feroz Muni", email: "feroz.muni.1920@gmail.com"))
        allUsers.append(User(id: 3, name: "Himanshu Choudhary", email: "himanshu.choudhary@yahoo.co.in"))
        allUsers.append(User(id: 4, name: "Hari Parikh", email: "hari.hari.p@gmail.com"))
        allUsers.append(User(id: 5, name: "Imran Parveen", email: "imran.parveen.1980@gmail.com"))
        allUsers.append(User(id: 6, name: "Valmiki Girsh", email: "valmiki.girish@gmail.com"))
        allUsers.append(User(id: 7, name: "Abhyagni Chellaiah", email: "abhyagni.chellaiah@gmail.com"))
        allUsers.append(User(id: 8, name: "Suresh Natasha", email: "suresh.natasha@gmail.com"))
        allUsers.append(User(id: 9, name: "Rupak Maudgalya", email: "rupak.mudgalya@gmail.com"))
        allUsers.append(User(id: 10, name: "Arjit Kanetkar", email: "arjit.kanetkar@gmail.com"))

        users.removeAll()
        users2.removeAll()
        while !allUsers.isEmpty {

            if Bool.random() {
                if let user = allUsers.randomElement(), let index = allUsers.firstIndex(of: user) {
                    users.append(user)
                    allUsers.remove(at: index)
                }
            } else {
                if let user = allUsers.randomElement(), let index = allUsers.firstIndex(of: user) {
                    users2.append(user)
                    allUsers.remove(at: index)
                }
            }

        }

        refreshUI()
    }

    @IBAction func empty(_ sender: UIBarButtonItem) {
        self.users.removeAll()
        self.users2.removeAll()
        refreshUI()
    }

    func refreshUI(animated: Bool = true) {

        if users.isEmpty && users2.isEmpty {
            tableView.tableHeaderView = nil
            tableView.tableFooterView = nil
        } else {
            tableView.tableHeaderView = headerView
            tableView.tableFooterView = footerView
        }

        let tableFrame: CGRect = tableView.frame
        list.reloadData({ [self] in

            let section1: IQSection
            switch Int.random(in: 0...2) {
            case 0:
                let headerSize: CGSize = CGSize(width: tableFrame.width, height: 50)
                section1 = IQSection(identifier: "firstSection",
                                     headerSize: headerSize)
            case 1:
                let header: String? = users.count > 0 ? "First Section header Title" : nil
                section1 = IQSection(identifier: "firstSection",
                                     header: header)
            case 2:
                section1 = IQSection(identifier: "firstSection",
                                     headerType: EmptyHeaderView.self,
                                     headerModel: .init(identifier: "firstSection", height: 10),
                                     footerType: EmptyTableHeaderFooterView.self, footerModel: "Footer Model")
            default:
                fatalError()
            }

            list.append([section1])
            list.append(UserCell.self, models: users, section: section1)

            let section2 = IQSection(identifier: "secondSection", header: users2.count > 0 ? "Second Section" : nil)
            list.append([section2])

            list.append(UserCell.self, models: users2, section: section2)

        }, animatingDifferences: animated)
    }
}

extension UserListTableViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQListView, modifyCell cell: some IQModelableCell, at indexPath: IndexPath) {
        if let cell = cell as? UserCell {
            cell.delegate = self
        }
    }

    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {
        if let model = item.model as? UserCell.Model {
            if let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "UserViewController") as? UserViewController {
                controller.user = model
//                controller.user = model
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView,
                            shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension UserListTableViewController: UserCellDelegate {
    func userCell(_ cell: UserCell, didDelete item: User) {
        if let index = users.firstIndex(of: item) {
            users.remove(at: index)
            refreshUI()
        } else if let index = users2.firstIndex(of: item) {
            users2.remove(at: index)
            refreshUI()
        }
    }
}
