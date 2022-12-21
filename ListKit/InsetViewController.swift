//
//  InsetViewController.swift
//  ListKit
//
//  Created by Iftekhar on 11/1/22.
//

import UIKit
import IQListKit

class InsetViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!

    private var defaultCellItems: [IQTableViewCell.Model] = []
    private var users = [User]()
    private var books = [Book]()

    private lazy var list = IQList(listView: tableView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchController = UISearchController()
        navigationItem.searchController = searchController

        list.noItemImage = UIImage(named: "empty")
        list.noItemTitle = "No Users"
        list.noItemMessage = "No users to display here."
        list.loadingMessage = "Loading..."
        list.noItemAction(title: "Reload", target: self, action: #selector(refresh(_:)))

//        tableView.tableFooterView = UIView()
        refreshUI(animated: false)
    }
}

extension InsetViewController {

    @IBAction func refresh(_ sender: Any) {

        var users = [User]()
        var defaultCellItems = [IQTableViewCell.Model]()
        var books = [Book]()

        switch Int.random(in: 1...3) {
        case 1:
            users.append(User(id: 1, name: "Sid Kumar", email: "sid.kumar1@gmail.com"))
            users.append(User(id: 2, name: "Feroz Muni", email: "feroz.muni.1920@gmail.com"))
            users.append(User(id: 3, name: "Himanshu Choudhary", email: "himanshu.choudhary@yahoo.co.in"))

            defaultCellItems.append(IQTableViewCell.Model(text: "1st cell", detail: "Loaded using Class"))
            defaultCellItems.append(IQTableViewCell.Model(text: "3rd cell", detail: "Loaded using Class"))
            defaultCellItems.append(IQTableViewCell.Model(text: "5th cell", detail: "Loaded using Class"))

            books.append(Book(id: 1, name: "The Great Gatsby"))
            books.append(Book(id: 2, name: "One Hundred Years of Solitude"))
            books.append(Book(id: 3, name: "A Passage to India"))

        case 2:
            users.append(User(id: 3, name: "Himanshu Choudhary", email: "himanshu.choudhary@yahoo.co.in"))
            users.append(User(id: 4, name: "Hari Parikh", email: "hari.hari.p@gmail.com"))

            defaultCellItems.append(IQTableViewCell.Model(text: "3rd cell", detail: "Loaded using Class"))
            defaultCellItems.append(IQTableViewCell.Model(text: "4th cell", detail: "Loaded using Class"))
            defaultCellItems.append(IQTableViewCell.Model(text: "5th cell", detail: "Loaded using Class"))

            books.append(Book(id: 1, name: "The Great Gatsby"))
            books.append(Book(id: 2, name: "One Hundred Years of Solitude"))
            books.append(Book(id: 3, name: "A Passage to India"))

        case 3:
            users.append(User(id: 1, name: "Sid Kumar", email: "sid.kumar1@gmail.com"))
            users.append(User(id: 3, name: "Himanshu Choudhary", email: "himanshu.choudhary@yahoo.co.in"))
            users.append(User(id: 4, name: "Hari Parikh", email: "hari.hari.p@gmail.com"))

            defaultCellItems.append(IQTableViewCell.Model(text: "1st cell", detail: "Loaded using Class"))
            defaultCellItems.append(IQTableViewCell.Model(text: "2nd cell", detail: "Loaded using Class"))
            defaultCellItems.append(IQTableViewCell.Model(text: "4th cell", detail: "Loaded using Class"))
            defaultCellItems.append(IQTableViewCell.Model(text: "5th cell", detail: "Loaded using Class"))

            books.append(Book(id: 1, name: "The Great Gatsby"))
            books.append(Book(id: 3, name: "A Passage to India"))
            books.append(Book(id: 4, name: "Invisible Man"))
        default:
            break
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

        list.setIsLoading(true, animated: animated)

        let dipatchTime: Double = (users.count == 0) ? 0 : 1

        DispatchQueue.main.asyncAfter(deadline: .now() + dipatchTime, execute: { [self] in
            list.reloadData({

                let section1 = IQSection(identifier: "firstSection")
                list.append([section1])

                for index in 0..<users.count {
                    if index < defaultCellItems.count {
                        let defaultCellItem = defaultCellItems[index]
                        list.append(IQTableViewCell.self, models: [defaultCellItem], section: section1)
                    }

                    let user = users[index]
                    list.append(UserCell.self, models: [user], section: section1)

                    if index < books.count {
                        let book = books[index]
                        list.append(BookCell.self, models: [book], section: section1)
                    }
                }

    //            list.append(IQTableViewCell.self, models: defaultCellItems, section: section1)
    //            list.append(UserCell.self, models: users, section: section1)
    //            list.append(BookCell.self, models: books, section: section1)

            }, animatingDifferences: animated)
        })
    }
}

extension InsetViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQListView, modifyCell cell: IQListCell, at indexPath: IndexPath) {
        if let cell = cell as? UserCell {
            cell.delegate = self
        } else if let cell = cell as? BookCell {
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
}

extension InsetViewController: UserCellDelegate {
    func userCell(_ cell: UserCell, didDelete item: User) {
        if let index = users.firstIndex(of: item) {
            users.remove(at: index)
            refreshUI()
        }
    }
}

extension InsetViewController: BookCellDelegate {
    func bookCell(_ cell: BookCell, didDelete item: Book) {
        if let index = books.firstIndex(of: item) {
            books.remove(at: index)
            refreshUI()
        }
    }
}
