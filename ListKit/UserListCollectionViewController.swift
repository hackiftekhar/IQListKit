//
//  UserListCollectionViewController.swift
//  ListKit
//
//  Created by iftekhar on 12/05/21.
//

import UIKit
import IQListKit

class UserListCollectionViewController: UICollectionViewController {

//    private var users1: [User] = []
//    private var users2: [User] = []

    private typealias StoryboardCell = CollectionUserStoryboardCell
    private typealias Cell = CollectionUserCell

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    private lazy var queue1 = DispatchQueue(label: "Queue1", attributes: .concurrent)
    private lazy var queue2 = DispatchQueue(label: "Queue2", attributes: .concurrent)
    private lazy var queue3 = DispatchQueue(label: "Queue3", attributes: .concurrent)
    private lazy var queue4 = DispatchQueue(label: "Queue4", attributes: .concurrent)
    private lazy var queue5 = DispatchQueue(label: "Queue5", attributes: .concurrent)

    private var testVar: Int = 0
    private let testLet: Int = 0

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

        refreshUI(users1: [], users2: [], animated: false)
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
        queue1.async {
            for _ in 1...100 {
                self.refresh()
            }
        }
        queue2.async {
            for _ in 1...100 {
                self.refresh()
            }
        }
        queue3.async {
            for _ in 1...100 {
                self.refresh()
            }
        }
        queue4.async {
            for _ in 1...100 {
                self.refresh()
            }
        }
        queue5.async {
            for _ in 1...100 {
                self.refresh()
            }
        }
    }

    private func refresh() {
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
        self.refreshUI(users1: users1.shuffled(), users2: users2.shuffled())
    }

    @IBAction func empty(_ sender: UIBarButtonItem) {
        refreshUI(users1: [], users2: [], animated: false)
    }

    func refreshUI(users1: [User], users2: [User], animated: Bool = true) {

        list.reloadData({ builder in
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
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension UserListCollectionViewController: CollectionUserCellDelegate {
    func userCell(_ cell: CollectionUserCell, didDelete item: User) {
//        if let index = users1.firstIndex(of: item) {
//            users1.remove(at: index)
//            refreshUI()
//        } else if let index = users2.firstIndex(of: item) {
//            users2.remove(at: index)
//            refreshUI()
//        }
    }
}

extension UserListCollectionViewController: CollectionUserStoryboardCellDelegate {
    func userCell(_ cell: CollectionUserStoryboardCell, didDelete item: User) {
//        if let index = users1.firstIndex(of: item) {
//            users1.remove(at: index)
//            refreshUI()
//        } else if let index = users2.firstIndex(of: item) {
//            users2.remove(at: index)
//            refreshUI()
//        }
    }
}
