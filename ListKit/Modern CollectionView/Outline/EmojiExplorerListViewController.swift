/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A collection view that uses a list layout
*/

import UIKit
import IQListKit

@available(iOS 14.0, *)
class EmojiExplorerListViewController: UIViewController {

    typealias Section = Emoji.Category

    struct Item: Hashable {
        let title: String
        let emoji: Emoji
        init(emoji: Emoji, title: String) {
            self.emoji = emoji
            self.title = title
        }
        private let identifier = UUID()
    }

    var collectionView: UICollectionView!
    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavItem()
        configureHierarchy()
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = self.collectionView.indexPathsForSelectedItems?.first {
            if let coordinator = self.transitionCoordinator {
                coordinator.animate(alongsideTransition: { _ in
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                }, completion: { (context) in
                    if context.isCancelled {
                        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    }
                })
            } else {
                self.collectionView.deselectItem(at: indexPath, animated: animated)
            }
        }
    }
}

@available(iOS 14.0, *)
extension EmojiExplorerListViewController {
    func configureNavItem() {
        navigationItem.title = "Emoji Explorer - List"
        navigationItem.largeTitleDisplayMode = .always
    }

    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        view.addSubview(collectionView)
    }

    func createLayout() -> UICollectionViewLayout {
        return IQCollectionViewLayout.listLayout(appearance: .insetGrouped)
    }
}

@available(iOS 14.0, *)
extension EmojiExplorerListViewController {

    private func configureDataSource() {

//        list.registerCell(type: EmojiListCell.self, registerType: .class)

        list.reloadData { [list] in

            for category in Emoji.Category.allCases.reversed() {
                let section = IQSection(identifier: category)
                list.append([section])

                let items = category.emojis.map { Item(emoji: $0, title: String(describing: category)) }
                list.append(EmojiListCell.self, models: items)
            }
        }
    }
}

@available(iOS 14.0, *)
extension EmojiExplorerListViewController: IQListViewDelegateDataSource {
    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {
        if let model = item.model as? EmojiListCell.Model {
            let detailViewController = EmojiDetailViewController(with: model.emoji)
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
}
