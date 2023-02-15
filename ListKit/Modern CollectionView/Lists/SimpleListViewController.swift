/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A basic list described by compositional layout
*/

import UIKit
import IQListKit

@available(iOS 14.0, *)
class SimpleListViewController: UIViewController {

    enum Section {
        case main
    }

    var collectionView: UICollectionView! = nil
    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "List"
        configureHierarchy()
        configureDataSource()
    }
}

@available(iOS 14.0, *)
extension SimpleListViewController {
    /// - Tag: List
    private func createLayout() -> UICollectionViewLayout {
        return IQCollectionViewLayout.listLayout(appearance: .insetGrouped)
    }
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
}

@available(iOS 14.0, *)
extension SimpleListViewController {
    private func configureDataSource() {

        list.registerCell(type: SimpleListCell.self, registerType: .class)
        
        list.reloadData {
            let sectionIdentifier = UUID()
            let section = IQSection(identifier: Section.main)
            list.append([section])

            let numbers = Array(0..<94)

            var items: [SimpleListCell.Model] = numbers.map { .init(section: sectionIdentifier, text: "\($0)") }

            list.append(SimpleListCell.self, models: items)
        }
    }
}

@available(iOS 14.0, *)
extension SimpleListViewController: IQListViewDelegateDataSource {
}
