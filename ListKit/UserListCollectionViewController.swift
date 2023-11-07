//
//  UserListCollectionViewController.swift
//  ListKit
//
//  Created by iftekhar on 12/05/21.
//

import UIKit
import IQListKit

class UserListCollectionViewController: UICollectionViewController {

    private var users1: [User] = []
    private var users2: [User] = []

    private typealias StoryboardCell = CollectionUserStoryboardCell
    private typealias Cell = CollectionUserCell

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        list.noItemStateView?.tintColor = UIColor.darkGray
        list.noItemImage = UIImage(named: "empty")
        list.noItemTitle = "No Users"
        list.noItemMessage = "No users to display here."
        list.noItemAction(title: "Reload", target: self, action: #selector(refresh(_:)))

        list.registerCell(type: Cell.self, registerType: .nib)
        list.registerCell(type: StoryboardCell.self, registerType: .storyboard)
//        list.registerSupplementaryView(type: SampleCollectionReusableView.self,
//                                       kind: UICollectionView.elementKindSectionHeader, registerType: .nib)

        refreshUI(animated: false)
    }
}

extension UserListCollectionViewController {

//    @IBAction func refresh(_ sender: Any) {
//
//        var allUsers: [User] = []
//        allUsers.append(User(id: 1, name: "Sid Kumar", email: "sid.kumar1@gmail.com"))
//        allUsers.append(User(id: 2, name: "Feroz Muni", email: "feroz.muni.1920@gmail.com"))
//        allUsers.append(User(id: 3, name: "Himanshu Choudhary", email: "himanshu.choudhary@yahoo.co.in"))
//        allUsers.append(User(id: 4, name: "Hari Parikh", email: "hari.hari.p@gmail.com"))
//        allUsers.append(User(id: 5, name: "Imran Parveen", email: "imran.parveen.1980@gmail.com"))
//        allUsers.append(User(id: 6, name: "Valmiki Girsh", email: "valmiki.girish@gmail.com"))
//        allUsers.append(User(id: 7, name: "Abhyagni Chellaiah", email: "abhyagni.chellaiah@gmail.com"))
//        allUsers.append(User(id: 8, name: "Suresh Natasha", email: "suresh.natasha@gmail.com"))
//        allUsers.append(User(id: 9, name: "Rupak Maudgalya", email: "rupak.mudgalya@gmail.com"))
//        allUsers.append(User(id: 10, name: "Arjit Kanetkar", email: "arjit.kanetkar@gmail.com"))
//
//        var users1: [User] = []
//        var users2: [User] = []
//        for user in allUsers {
//
//            if Bool.random() {
//                users1.append(user)
//            } else {
//                users2.append(user)
//            }
//        }
//
//        self.users1 = users1.shuffled()
//        self.users2 = users2.shuffled()
//        self.refreshUI()
//    }

    @IBAction func refresh(_ sender: Any) {

        DispatchQueue.global().async {
            for _ in 1...1000 {
                DispatchQueue.global().async {
                    var allUsers: [User] = []

                    for id in 1...1000 {
                        allUsers.append(User(id: id, name: "Sid Kumar", email: "sid.kumar1@gmail.com"))
                    }

                    var users1: [User] = []
                    var users2: [User] = []
                    for user in allUsers {

                        if Bool.random() {
                            users1.append(user)
                        } else {
                            users2.append(user)
                        }
                    }

                    DispatchQueue.main.async { [users1, users2] in
                        self.users1 = users1.shuffled()
                        self.users2 = users2.shuffled()
                        self.refreshUI()
                    }
                }
            }
        }
    }

    @IBAction func empty(_ sender: UIBarButtonItem) {
        self.users1.removeAll()
        self.users2.removeAll()
        refreshUI()
    }

    func refreshUI(animated: Bool = true) {

        list.reloadData({ [users1, users2] builder in

            let section1: IQSection
            if Bool.random() {
                section1 = IQSection(identifier: "firstSection",
                                     headerType: SampleCollectionReusableView.self,
                                     headerModel: .init(color: UIColor.red))
            } else {
                section1 = IQSection(identifier: "firstSection", header: "First Section")
            }
            builder.append([section1])

            for user in users1 {
                if Bool.random() {
                    builder.append(Cell.self, models: [user], section: section1)
                } else {
                    builder.append(StoryboardCell.self, models: [user], section: section1)
                }
            }

            let section2: IQSection
            if Bool.random() {
                section2 = IQSection(identifier: "secondSection",
                                     headerType: SampleCollectionReusableView.self,
                                     headerModel: .init(color: UIColor.green))
            } else {
                section2 = IQSection(identifier: "secondSection", header: "Second Section")
            }

            builder.append([section2])

            for user in users2 {
                if Bool.random() {
                    builder.append(Cell.self, models: [user], section: section2)
                } else {
                    builder.append(StoryboardCell.self, models: [user], section: section2)
                }
            }

        }, animatingDifferences: animated)
    }
}

extension UserListCollectionViewController: IQListViewDelegateDataSource {

    func listView(_ listView: IQListView, modifyCell cell: some IQModelableCell, at indexPath: IndexPath) {
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

extension UserListCollectionViewController: CollectionUserCellDelegate {
    func userCell(_ cell: CollectionUserCell, didDelete item: User) {
        if let index = users1.firstIndex(of: item) {
            users1.remove(at: index)
            refreshUI()
        } else if let index = users2.firstIndex(of: item) {
            users2.remove(at: index)
            refreshUI()
        }
    }
}

extension UserListCollectionViewController: CollectionUserStoryboardCellDelegate {
    func userCell(_ cell: CollectionUserStoryboardCell, didDelete item: User) {
        if let index = users1.firstIndex(of: item) {
            users1.remove(at: index)
            refreshUI()
        } else if let index = users2.firstIndex(of: item) {
            users2.remove(at: index)
            refreshUI()
        }
    }
}
