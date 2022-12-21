//
//  UserListCollectionViewController.swift
//  ListKit
//
//  Created by iftekhar on 12/05/21.
//

import UIKit
import IQListKit

class UserListCollectionViewController: UICollectionViewController {

    private var users: [User] = []
    private var users2: [User] = []

    private typealias StoryboardCell = CollectionUserStoryboardCell
    private typealias Cell = CollectionUserCell

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        list.noItemImage = UIImage(named: "empty")
        list.noItemTitle = "No Users"
        list.noItemMessage = "No users to display here."
        list.noItemAction(title: "Reload", target: self, action: #selector(refresh(_:)))

        list.registerCell(type: CollectionUserCell.self, registerType: .nib)
        list.registerHeaderFooter(type: SampleCollectionReusableView.self, registerType: .nib)

        refreshUI(animated: false)
    }
}

extension UserListCollectionViewController {

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
        for user in allUsers {

            if Bool.random() {
                users.append(user)
            } else {
                users2.append(user)
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

        list.reloadData({

//            let firstView = UIView()
//            firstView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//            firstView.backgroundColor = UIColor.red
//
//            let secondView = UIView()
//            secondView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//            secondView.backgroundColor = UIColor.yellow

            let section1 = IQSection(identifier: "firstSection", header: "First Section")
//            let section1 = IQSection(identifier: "firstSection", header: "First Section", headerView: firstView)
            list.append([section1])

            for user in users {
                if Bool.random() {
                    list.append(Cell.self, models: [user], section: section1)
                } else {
                    list.append(StoryboardCell.self, models: [user], section: section1)
                }
            }

            let section2 = IQSection(identifier: "secondSection", header: "Second Section")
//            let section2 = IQSection(identifier: "secondSection", header: "Second Section", headerView: secondView)
            list.append([section2])

            for user in users2 {
                if Bool.random() {
                    list.append(Cell.self, models: [user], section: section2)
                } else {
                    list.append(StoryboardCell.self, models: [user], section: section2)
                }
            }

        }, animatingDifferences: animated, completion: nil)
    }
}

extension UserListCollectionViewController: IQListViewDelegateDataSource {

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

    func listView(_ listView: IQListView, didEndDisplaying cell: IQListCell, at indexPath: IndexPath) {
    }

    func listView(_ listView: IQListView, headerFor section: IQSection, at sectionIndex: Int) -> UIView? {
        let indexPath = IndexPath(item: 0, section: sectionIndex)
        let headerView = collectionView.dequeue(SampleCollectionReusableView.self,
                                                kind: UICollectionView.elementKindSectionHeader,
                                                for: indexPath)
        return headerView
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}

extension UserListCollectionViewController: CollectionUserCellDelegate {
    func userCell(_ cell: CollectionUserCell, didDelete item: User) {
        if let index = users.firstIndex(of: item) {
            users.remove(at: index)
            refreshUI()
        } else if let index = users2.firstIndex(of: item) {
            users2.remove(at: index)
            refreshUI()
        }
    }
}

extension UserListCollectionViewController: CollectionUserStoryboardCellDelegate {
    func userCell(_ cell: CollectionUserStoryboardCell, didDelete item: User) {
        if let index = users.firstIndex(of: item) {
            users.remove(at: index)
            refreshUI()
        } else if let index = users2.firstIndex(of: item) {
            users2.remove(at: index)
            refreshUI()
        }
    }
}
