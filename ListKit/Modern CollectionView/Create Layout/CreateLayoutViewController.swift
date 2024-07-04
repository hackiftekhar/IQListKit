//
//  CreateLayoutViewController.swift
//  ListKit
//
//  Created by Iftekhar on 2/10/23.
//

import UIKit
import IQListKit

// swiftlint:disable file_length

extension NSDirectionalEdgeInsets: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine( self.top)
        hasher.combine( self.bottom)
        hasher.combine( self.leading)
        hasher.combine( self.trailing)
    }
}

@available(iOS 14.0, *)
@MainActor
protocol CreateLayoutViewControllerDelegate: AnyObject {
    @MainActor func createLayoutController(_ controller: CreateLayoutViewController,
                                           didUpdate layout: CreateLayoutViewController.Layout)
}

@available(iOS 14.0, *)
class CreateLayoutViewController: UIViewController {

    @MainActor
    class Item {
        var layoutSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                                                        heightDimension: .fractionalHeight(1.0))

        var contentInsets: NSDirectionalEdgeInsets = .zero
        var edgeSpacing: NSCollectionLayoutEdgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0),
                                                                                       top: .fixed(0),
                                                                                       trailing: .fixed(0),
                                                                                       bottom: .fixed(0))

        func create() -> NSCollectionLayoutItem {
            let item = NSCollectionLayoutItem(layoutSize: layoutSize)
            item.contentInsets = contentInsets
            item.edgeSpacing = edgeSpacing
            return item
        }

        func getCode() -> String {

            var code = ""

            code += """
            var itemLayoutSize: NSCollectionLayoutSize = \(layoutSize.toString())
            let item = NSCollectionLayoutItem(layoutSize: itemLayoutSize)
            """

            if contentInsets != .zero {
                code += "\n\titem.contentInsets = \(contentInsets.toString())"
            }
            if !edgeSpacing.isEmpty {
                code += "\n\titem.edgeSpacing = \(edgeSpacing.toString())"
            }

            return code
        }
    }

    @MainActor
    class Group: Item {
        var subitems: [Item] = [Item()]

        override init() {
            super.init()
            layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalWidth(0.2))
        }
        var direction: UICollectionView.ScrollDirection = .vertical
        var count: Int = 1
        var interItemSpacing: NSCollectionLayoutSpacing = NSCollectionLayoutSpacing.fixed(0)

        override func create() -> NSCollectionLayoutGroup {

            let group: NSCollectionLayoutGroup
            let subitems = subitems.map { $0.create() }
            switch direction {
            case .horizontal:
                if count > 1 {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: layoutSize,
                                                             subitem: subitems.first!,
                                                             count: count)
                } else {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: layoutSize,
                                                             subitems: subitems)
                }
            case .vertical:
                if count > 1 {
                    group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize,
                                                               subitem: subitems.first!,
                                                               count: count)
                } else {
                    group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize,
                                                               subitems: subitems)
                }
            @unknown default:
                fatalError("Unsupported direction")
            }

            group.interItemSpacing = interItemSpacing
            group.contentInsets = contentInsets
            group.edgeSpacing = edgeSpacing
            return group
        }

        // swiftlint:disable cyclomatic_complexity
        // swiftlint:disable function_body_length
        override func getCode() -> String {
            var code = ""

            let itemVariableName: String
            if count > 1 {
                itemVariableName = "item"
                code += self.subitems.first?.getCode() ?? ""
            } else {

                if subitems.count == 1 {
                    itemVariableName = "[item]"
                    code += self.subitems.first?.getCode() ?? ""

                } else {
                    itemVariableName = "subitems"

                    code += """
                            var subitems: [NSCollectionLayoutItem] = []
                            """
                    for subitem in subitems {
                        code += "\n\tdo {\n"

                        code += subitem.getCode()
                        code += "\n\tsubitems.append(item)"
                        code += "\n\t}"
                    }
                    code += "\n"
                }
            }

            code += """

            var groupLayoutSize: NSCollectionLayoutSize = \(layoutSize.toString())

            """

            // swiftlint:disable line_length
            switch direction {
            case .vertical:
                if count > 1 {
                    code += """
                            let group: NSCollectionLayoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupLayoutSize,
                                                                                          subitem: \(itemVariableName),
                                                                                          count: \(count))
                            """
                } else {
                    code += """
                            let group: NSCollectionLayoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupLayoutSize,
                                                                                          subitems: \(itemVariableName))
                            """
                }
            case .horizontal:
                if count > 1 {
                    code += """
                            let group: NSCollectionLayoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupLayoutSize,
                                                                                          subitem: \(itemVariableName),
                                                                                          count: \(count))
                            """
                } else {
                    code += """
                            let group: NSCollectionLayoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupLayoutSize,
                                                                                          subitems: \(itemVariableName))
                            """
                }
            @unknown default:
                break
            }
            // swiftlint:enable line_length

            if !(interItemSpacing.isFixed && interItemSpacing.spacing == 0) {
                code += "\ngroup.interItemSpacing = \(interItemSpacing.toString())"
            }
            if contentInsets != .zero {
                code += "\ngroup.contentInsets = \(contentInsets.toString())"
            }
            if !edgeSpacing.isEmpty {
                code += "\ngroup.edgeSpacing = \(edgeSpacing.toString())"
            }

            return code
        }
        // swiftlint:enable cyclomatic_complexity
        // swiftlint:enable function_body_length
    }

    @MainActor
    class Section {
        var group: Group = Group()

        var contentInsets: NSDirectionalEdgeInsets = .zero
        var interGroupSpacing: CGFloat = 0
        var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none

        func create() -> NSCollectionLayoutSection {
            let section = NSCollectionLayoutSection(group: group.create())
            section.contentInsets = contentInsets
            section.interGroupSpacing = interGroupSpacing
            section.orthogonalScrollingBehavior = orthogonalScrollingBehavior
            return section
        }

        func getCode() -> String {

            var code = ""
            code += group.getCode()
            code += "\n\nlet section = NSCollectionLayoutSection(group: group)"
            if contentInsets != .zero {
                code += "\nsection.contentInsets = \(contentInsets.toString())"
            }
            if interGroupSpacing != 0 {
                code += "\nsection.interGroupSpacing = \(interGroupSpacing)"
            }
            if orthogonalScrollingBehavior != .none {
                code += "\nsection.orthogonalScrollingBehavior = \(orthogonalScrollingBehavior.toString())"
            }

            return code
        }
    }

    @MainActor
    class Layout {
        var section: Section = Section()

        var scrollDirection: UICollectionView.ScrollDirection = .vertical
        var interSectionSpacing: CGFloat = 0

        func create() -> UICollectionViewLayout {

            let configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
            configuration.scrollDirection = scrollDirection
            configuration.interSectionSpacing = interSectionSpacing
            let layout = UICollectionViewCompositionalLayout(section: section.create(), configuration: configuration)
            return layout
        }

        func getCode() -> String {

            var code = "----------Layout Code Start----------\n\n"
            code += section.getCode()
            code += "\n\nlet configuration: UICollectionViewCompositionalLayoutConfiguration = .init()"
            if scrollDirection == .horizontal {
                code += "\nconfiguration.scrollDirection = \(scrollDirection.toString())"
            }
            if interSectionSpacing != 0 {
                code += "\nconfiguration.interSectionSpacing = \(interSectionSpacing)"
            }

            code += "\nlet layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)"
            code += "\n\n----------Layout Code End----------"
            return code
        }
    }

    weak var delegate: CreateLayoutViewControllerDelegate?

    var layout = Layout()

    var collectionView: UICollectionView! = nil

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self, reloadQueue: .main)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Create Layout"
        configureHierarchy()

        list.registerCell(type: CustomLayoutCell.self, registerType: .class)

        let doneBarButton = UIBarButtonItem(systemItem: .done, primaryAction: UIAction(handler: { _ in
            self.delegate?.createLayoutController(self, didUpdate: self.layout)
            self.dismiss(animated: true)
        }))

        let printBarButton = UIBarButtonItem(title: "Print Code", primaryAction: UIAction(handler: { _ in
            let code = self.layout.getCode()
            print(code)
        }))
        self.navigationItem.leftBarButtonItem = printBarButton
        self.navigationItem.rightBarButtonItem = doneBarButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadDataSource()
    }
}

@available(iOS 14.0, *)
extension CreateLayoutViewController {
    /// - Tag: Grid
    private func createLayout() -> UICollectionViewLayout {

        return IQCollectionViewLayout.listLayout(appearance: .plain)
    }

    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
}

@available(iOS 14.0, *)
extension CreateLayoutViewController {

    // swiftlint:disable function_body_length
    // swiftlint:disable line_length
    // swiftlint:disable comma
    private func reloadDataSource() {

        var sectionSnapshot = IQDiffableDataSourceSectionSnapshot()

        let expandedItems: [IQItem]
        let customizeSection: IQSection
        if let section = list.snapshot().sectionIdentifiers.first {
            customizeSection = section
            let existingSnapshot = list.snapshot(for: customizeSection)
            expandedItems = existingSnapshot.items.compactMap { existingSnapshot.isExpanded($0) ? $0 : nil }
        } else {
            customizeSection = IQSection(identifier: "CreateLayout")
            expandedItems = []
        }

        let layoutItem = IQItem(CustomLayoutCell.self, model: .init(path: "layout", title: "Layout", value: "", haveSubitems: true))
        sectionSnapshot.append([layoutItem])

        let scrollDirection = IQItem(CustomLayoutCell.self, model: .init(path: "layout.scrollDirection", title: "scrollDirection", value: layout.scrollDirection, haveSubitems: false))
        let interSectionSpacing = IQItem(CustomLayoutCell.self, model: .init(path: "layout.interSectionSpacing",title: "Inter Section Spacing",value: layout.interSectionSpacing, haveSubitems: false))
        let section = IQItem(CustomLayoutCell.self, model: .init(path: "layout.section",title: "Section", value: "", haveSubitems: true))

        sectionSnapshot.append([scrollDirection, interSectionSpacing, section], to: layoutItem)

        do {
            let contentInsets = IQItem(CustomLayoutCell.self, model: .init(path: "layout.section.contentInsets", title: "Content Insets", value: layout.section.contentInsets, haveSubitems: false))
            let interGroupSpacing = IQItem(CustomLayoutCell.self, model: .init(path: "layout.section.interGroupSpacing", title: "Inter Section Spacing",
                                                                               value: layout.section.interGroupSpacing, haveSubitems: false))
            let orthogonalScrollingBehavior = IQItem(CustomLayoutCell.self, model: .init(path: "layout.section.orthogonalScrollingBehavior",
                                                                                         title: "Orthogonal Scrolling Behavior",
                                                                                         value: layout.section.orthogonalScrollingBehavior,
                                                                                         haveSubitems: false))

            sectionSnapshot.append([contentInsets, interGroupSpacing, orthogonalScrollingBehavior], to: section)

            func appendGroupToItem(path: String, index: Int, group: Group, to item: IQItem, canRemove: Bool) {

                let name: String
                if index == -1 {
                    name = "Group"
                } else {
                    name = "Item \(index+1) (Group)"
                }

                let groupItem = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group", title: name, value: "", haveSubitems: true))
                sectionSnapshot.append([groupItem], to: item)

                let addItem = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group.addItem", title: "Add New Item", value: CustomLayoutCell.EditingAction.addNewItem, color: UIColor.systemGreen, haveSubitems: false))
                sectionSnapshot.append([addItem], to: groupItem)
                if canRemove {
                    let removeGroup = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).removeItem",title: "Remove Group",value: CustomLayoutCell.EditingAction.removeItem, color: UIColor.systemRed, haveSubitems: false))
                    sectionSnapshot.append([removeGroup], to: groupItem)
                }

                let layoutSize = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group.layoutSize",
                                                                            title: "Layout Size",
                                                                            value: group.layoutSize,
                                                                            haveSubitems: false))
                let edgeSpacing = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group.edgeSpacing", title: "Edge Spacing", value: group.edgeSpacing, haveSubitems: false))
                let direction = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group.direction", title: "Direction", value: group.direction, haveSubitems: false))
                let count = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group.count",title: "Count",value: group.count, haveSubitems: false))
                let interItemSpacing = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group.interItemSpacing",title: "Inter Item Spacing", value: group.interItemSpacing, haveSubitems: false))
                let contentInsets = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group.contentInsets", title: "Content Insets", value: group.contentInsets, haveSubitems: false))

                sectionSnapshot.append([layoutSize, edgeSpacing, direction, count, interItemSpacing, contentInsets], to: groupItem)

                let canRemove = group.subitems.count > 1

                for (index, subitem) in group.subitems.enumerated() {
                    if let group = subitem as? Group {
                        appendGroupToItem(path: "\(path).group.item[\(index)]", index: index, group: group, to: groupItem, canRemove: canRemove)
                    } else {
                        let listItem = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group.item[\(index)]", title: "Item \(index+1)", value: "", haveSubitems: true))
                        sectionSnapshot.append([listItem], to: groupItem)

                        if canRemove {
                            let removeItem = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group.item[\(index)].removeItem",title: "Remove Item",value: CustomLayoutCell.EditingAction.removeItem, color: UIColor.systemRed, haveSubitems: false))
                            sectionSnapshot.append([removeItem], to: listItem)
                        }

                        let layoutSize = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group.item[\(index)].layoutSize",
                                                                                    title: "Layout Size",
                                                                                    value: subitem.layoutSize,
                                                                                    haveSubitems: false))
                        let edgeSpacing = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group.item[\(index)].edgeSpacing",title: "Edge Spacing", value: subitem.edgeSpacing, haveSubitems: false))

                        let contentInsets = IQItem(CustomLayoutCell.self, model: .init(path: "\(path).group.item[\(index)].contentInsets",title: "Content Insets",value: subitem.contentInsets, haveSubitems: false))
                        sectionSnapshot.append([layoutSize, edgeSpacing, contentInsets], to: listItem)
                    }
                }
            }

            appendGroupToItem(path: "layout.section", index: -1, group: layout.section.group, to: section, canRemove: false)
        }

        if !expandedItems.isEmpty {
            sectionSnapshot.expand(expandedItems)
        } else {
            let headerItems: [IQItem] = sectionSnapshot.items.filter { item in
                if let model = item.model as? CustomLayoutCell.Model {
                    return model.haveSubitems
                }
                return false
            }

            if !headerItems.isEmpty {
                sectionSnapshot.expand(headerItems)
            }
        }

        list.apply(sectionSnapshot, to: customizeSection, animatingDifferences: false, completion: nil)
    }
}

@available(iOS 14.0, *)
extension CreateLayoutViewController: IQListViewDelegateDataSource {
    func listView(_ listView: IQListView, modifyCell cell: some IQModelableCell, at indexPath: IndexPath) {
        if let cell = cell as? CustomLayoutCell {
            cell.delegate = self
        }
    }
}

@available(iOS 14.0, *)
extension CreateLayoutViewController: CustomLayoutCellDelegate {

    // swiftlint:disable cyclomatic_complexity
    func collectionLayoutCell(_ cell: CustomLayoutCell, didChanged value: AnyHashable, at path: String) {
        switch path {
        case "layout.scrollDirection":
            if let value = value as? UICollectionView.ScrollDirection {
                layout.scrollDirection = value
            }
        case "layout.interSectionSpacing":
            if let value = value as? CGFloat {
                layout.interSectionSpacing = value
            }
        case "layout.section.contentInsets":
            if let value = value as? NSDirectionalEdgeInsets {
                layout.section.contentInsets = value
            }
        case "layout.section.interGroupSpacing":
            if let value = value as? CGFloat {
                layout.section.interGroupSpacing = value
            }
        case "layout.section.orthogonalScrollingBehavior":
            if let value = value as? UICollectionLayoutSectionOrthogonalScrollingBehavior {
                layout.section.orthogonalScrollingBehavior = value
            }
        default:
            let innerPath = path.deletingPrefix("layout.section.group.")

            CreateLayoutViewController.handleValue(value: value, path: innerPath, for: layout.section.group)
        }

        self.delegate?.createLayoutController(self, didUpdate: self.layout)
        reloadDataSource()
    }

    static func handleValue(value: AnyHashable, path: String, for group: Group) {

        switch path {
        case "layoutSize":
            if let value = value as? NSCollectionLayoutSize {
                group.layoutSize = value
            }

        case "edgeSpacing":
            if let value = value as? NSCollectionLayoutEdgeSpacing {
                group.edgeSpacing = value
            }
        case "direction":
            if let value = value as? UICollectionView.ScrollDirection {
                group.direction = value
            }
        case "count":
            if let value = value as? Int {
                group.count = value
            }
        case "interItemSpacing":
            if let value = value as? NSCollectionLayoutSpacing {
                group.interItemSpacing = value
            }
        case "contentInsets":
            if let value = value as? NSDirectionalEdgeInsets {
                group.contentInsets = value
            }
        case "addItem":
            if let value = value as? CustomLayoutCell.ItemType {
                switch value {
                case .item:
                    group.subitems.append(Item())
                case .group:
                    group.subitems.append(Group())
                }
            }
        default:

            var innerPath = path.deletingPrefix("item[")
            let stringIndex = innerPath.index(innerPath.startIndex, offsetBy: 1)
            let index: Int = Int(String(innerPath[..<stringIndex])) ?? 0
            innerPath = innerPath.deletingPrefix("\(index)].")

            let item = group.subitems[index]

            if innerPath == "removeItem" {
                group.subitems.remove(at: index)
            } else {
                if let group = item as? Group {
                    innerPath = innerPath.deletingPrefix("group.")
                    handleValue(value: value, path: innerPath, for: group)
                } else {
                    switch innerPath {
                    case "layoutSize":
                        if let value = value as? NSCollectionLayoutSize {
                            item.layoutSize = value
                        }
                    case "edgeSpacing":
                        if let value = value as? NSCollectionLayoutEdgeSpacing {
                            item.edgeSpacing = value
                        }
                    case "contentInsets":
                        if let value = value as? NSDirectionalEdgeInsets {
                            item.contentInsets = value
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
// swiftlint:enable file_length
