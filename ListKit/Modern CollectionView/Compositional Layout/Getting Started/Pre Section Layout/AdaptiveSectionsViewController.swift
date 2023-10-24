/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A layout that adapts to a changing layout environment
*/

import UIKit
import IQListKit

class AdaptiveSectionsViewController: UIViewController {

    enum SectionLayoutKind: Int, CaseIterable {
        case list, grid5, grid3
        func columnCount(for width: CGFloat) -> Int {
            let wideMode = width > 800
            switch self {
            case .grid3:
                return wideMode ? 6 : 3

            case .grid5:
                return wideMode ? 10 : 5

            case .list:
                return wideMode ? 2 : 1
            }
        }
    }

    var collectionView: UICollectionView! = nil

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Adaptive Sections"
        configureHierarchy()
        configureDataSource()
    }
}

extension AdaptiveSectionsViewController {
    /// - Tag: Adaptive
    func createLayout() -> UICollectionViewLayout {
        // swiftlint:disable line_length
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
            -> NSCollectionLayoutSection? in
            // swiftlint:enable line_length

            let sectionIdentifier = self.list.sectionIdentifiers[sectionIndex]
            guard let layoutKind = sectionIdentifier.identifier as? SectionLayoutKind else { return nil }

            let columns = layoutKind.columnCount(for: layoutEnvironment.container.effectiveContentSize.width)

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                                 heightDimension: .fractionalHeight(1.0))

            let groupHeight: NSCollectionLayoutDimension
            switch layoutKind {
            case .list:
                groupHeight = NSCollectionLayoutDimension.absolute(44)
            case .grid3, .grid5:
                groupHeight = NSCollectionLayoutDimension.fractionalWidth(0.2)
            }

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: groupHeight)

            let itemContentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            let section = IQCollectionViewSectionLayout.sectionLayout(direction: .horizontal,
                                                                      itemSize: itemSize,
                                                                      itemContentInsets: itemContentInsets,
                                                                      groupSize: groupSize,
                                                                      gridCount: columns)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
            return section
        }
        return layout
    }
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
}

extension AdaptiveSectionsViewController {
    func configureDataSource() {

//        list.registerCell(type: TextCell.self, registerType: .class)
//        list.registerCell(type: ListCell.self, registerType: .class)

        list.reloadData { [list] in

            SectionLayoutKind.allCases.forEach {
                let section = IQSection(identifier: $0)
                list.append([section])

                let itemsPerSection = 10
                let itemOffset = $0.rawValue * itemsPerSection
                let itemUpperbound = itemOffset + itemsPerSection
                let numbers = Array(itemOffset..<itemUpperbound)

                switch $0 {
                case .list:
                    let items: [ListCell.Model] = numbers.map { .init(text: "\($0)") }
                    list.append(ListCell.self, models: items)
                case .grid5:
                    let items: [TextCell.Model] = numbers.map { .init(text: "\($0)", cornerRadius: 8, badgeCount: 0) }
                    list.append(TextCell.self, models: items)
                case .grid3:
                    let items: [TextCell.Model] = numbers.map { .init(text: "\($0)", cornerRadius: 0, badgeCount: 0) }
                    list.append(TextCell.self, models: items)
                }
            }
        }
    }
}

extension AdaptiveSectionsViewController: IQListViewDelegateDataSource {
}
