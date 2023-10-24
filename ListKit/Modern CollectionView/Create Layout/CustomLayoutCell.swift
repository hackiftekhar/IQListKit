//
//  CustomLayoutCell.swift
//  ListKit
//
//  Created by Iftekhar on 2/13/23.
//

import UIKit
import IQListKit

// swiftlint:disable file_length

@available(iOS 14.0, *)
@MainActor
protocol CustomLayoutCellDelegate: AnyObject {
    @MainActor func collectionLayoutCell(_ cell: CustomLayoutCell, didChanged value: AnyHashable, at path: String)
}

@available(iOS 14.0, *)
class CustomLayoutCell: UICollectionViewListCell, IQModelableCell {

    enum EdgeDirection: String, CaseIterable {
        case all        =   "All"
        case top        =   "Top"
        case leading    =   "Leading"
        case bottom     =   "Bottom"
        case trailing   =   "Trailing"
    }

    let menuButton = UIButton(type: .system)
    private var optionMenu: UIMenu!
    var allActions: [EditingAction: [UIMenuElement]] = [:]

    weak var delegate: CustomLayoutCellDelegate?

    struct Model: Hashable, @unchecked Sendable {

        func hash(into hasher: inout Hasher) {
            hasher.combine(path)
        }

        let path: String
        let title: String
        var value: AnyHashable
        var color: UIColor?
        let haveSubitems: Bool
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureMenuButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureMenuButton()
    }

    var model: Model? {
        didSet {
            guard let model = model else { return }

            var contentConfiguration = UIListContentConfiguration.subtitleCell()
            if let color = model.color {
                contentConfiguration.textProperties.color = color
            }
            contentConfiguration.text = model.title

            var newActions: [UIMenuElement] = []

            switch model.value {
            case let value as EditingAction:
                if let actions = allActions[value] {
                    newActions.append(contentsOf: actions)
                }
            case let value as String:
                contentConfiguration.secondaryText = value
            case let value as CGFloat:

                if model.value.base is Int, let value = model.value as? Int {
                    contentConfiguration.secondaryText = "\(value)"

                    if let actions = allActions[.count] {
                        newActions.append(contentsOf: actions)
                    }
                } else {
                    contentConfiguration.secondaryText = "\(value)"

                    if let actions = allActions[.floatValue] {
                        newActions.append(contentsOf: actions)
                    }
                }

            case let value as NSDirectionalEdgeInsets:
                contentConfiguration.secondaryText = """
                                                    Top: \(value.top), \
                                                    Leading: \(value.leading), \
                                                    Bottom \(value.bottom), \
                                                    Trailing: \(value.trailing)
                                                    """

                if let actions = allActions[.directionalEdgeInsets] {
                    newActions.append(contentsOf: actions)
                }
            case let value as UICollectionLayoutSectionOrthogonalScrollingBehavior:

                typealias OrthogonalBehaviour = UICollectionLayoutSectionOrthogonalScrollingBehavior
                let supportedValues: [OrthogonalBehaviour] = [.none,
                                                              .continuous,
                                                              .continuousGroupLeadingBoundary,
                                                              .paging,
                                                              .groupPaging,
                                                              .groupPagingCentered]
                let supportedValuesDisplay: [String] =  ["None", "Continuous",
                                                         "Continuous Group Leading Boundary",
                                                         "Paging",
                                                         "Group Paging",
                                                         "Group Paging Centered"]

                if let index = supportedValues.firstIndex(of: value) {
                    contentConfiguration.secondaryText = supportedValuesDisplay[index]
                }

                if let actions = allActions[.orthogonalScrollingBehavior] {
                    newActions.append(contentsOf: actions)
                }

            case let value as UICollectionView.ScrollDirection:
                contentConfiguration.secondaryText = value.toString()

                if let actions = allActions[.scrollDirection] {
                    newActions.append(contentsOf: actions)
                }

            case let value as NSCollectionLayoutSize:

                var title: String = value.widthDimension.toString()
                title += ", "
                title += value.heightDimension.toString()

                contentConfiguration.secondaryText = title
                if let actions = allActions[.layoutSize] {
                    newActions.append(contentsOf: actions)
                }

            case let value as NSCollectionLayoutEdgeSpacing:
                var title: String = ""
                title += value.top?.toString() ?? "nil"
                title += ", "
                title += value.leading?.toString() ?? "nil"
                title += ", "
                title += value.bottom?.toString() ?? "nil"
                title += ", "
                title += value.trailing?.toString() ?? "nil"

                contentConfiguration.secondaryText = title

                if let actions = allActions[.edgeSpacing] {
                    newActions.append(contentsOf: actions)
                }
            case let value as NSCollectionLayoutSpacing:

                contentConfiguration.secondaryText = value.toString()

                if let actions = allActions[.layoutSpacing] {
                    newActions.append(contentsOf: actions)
                }

            default:
                contentConfiguration.secondaryText = String(describing: model.value)
            }

            if !model.haveSubitems {
                self.contentConfiguration = contentConfiguration
                accessories = []

                if newActions.isEmpty {
                    menuButton.isHidden = true
                } else {
                    menuButton.isHidden = false
                    self.optionMenu = self.optionMenu.replacingChildren(newActions)
                    menuButton.menu = self.optionMenu

                    self.contentView.addSubview(menuButton)
                    menuButton.translatesAutoresizingMaskIntoConstraints = false
                    menuButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
                    menuButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
                    menuButton.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
                    menuButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
                }
            } else {

                menuButton.isHidden = true

                contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
                self.contentConfiguration = contentConfiguration

                let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
                accessories = [.outlineDisclosure(options: disclosureOptions)]
            }
        }
    }

    func updateValue(value: AnyHashable) {
        guard let model = model else { return }
        delegate?.collectionLayoutCell(self, didChanged: value, at: model.path)
    }
}

@available(iOS 14.0, *)
extension CustomLayoutCell {

    enum ItemType: String, CaseIterable, Hashable {
        case item   =   "Item"
        case group  =   "Group"
    }

    private enum Dimension: String, CaseIterable {
        case flexible   =   "Flexible"
        case fixed      =   "Fixed"
    }

    private enum LayoutDimension: String, CaseIterable {
        case fractionalWidth    =   "Fractional Width"
        case fractionalHeight   =   "Fractional Height"
        case absolute           =   "Absolute"
        case estimated          =   "Estimated"
    }

    enum LayoutDirection: String, CaseIterable {
        case all          =   "All"
        case width        =   "Width"
        case height       =   "Height"
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable line_length
    // swiftlint:disable cyclomatic_complexity
    private func configureMenuButton() {

        for option in EditingAction.allCases {

            switch option {
            case .scrollDirection:
                let supportedValues: [UICollectionView.ScrollDirection] = [.horizontal, .vertical]
                var actions: [UIMenuElement] = []
                for value in supportedValues {
                    let identifier: String = option.rawValue + String(describing: value)
                    let title: String = value == .horizontal ? "Horizontal" : "Vertical"
                    let action: UIAction = UIAction(title: title, image: nil, identifier: .init(identifier), handler: { [self] _ in
                        updateValue(value: value)
                    })
                    actions.append(action)
                }

                allActions[option] = actions
            case .floatValue:

                let supportedValues: [CGFloat] = [0.0, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0, 150.0, 200.0, 300.0]
                let actions: [UIAction] = floatActions(values: supportedValues, initialIdentifier: option.rawValue)

                allActions[option] = actions
            case .directionalEdgeInsets:

                let supportedValues: [CGFloat] = [0.0, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0]
                var actions: [UIAction] = []
                for value in supportedValues {
                    let identifier: String  = option.rawValue + String(describing: value)
                    let title: String  = "\(value)"
                    let action: UIAction = UIAction(title: title, image: nil, identifier: .init(identifier), handler: { [self] _ in
                        let value = NSDirectionalEdgeInsets(top: value, leading: value, bottom: value, trailing: value)
                        updateValue(value: value)
                    })
                    actions.append(action)
                }

                allActions[option] = actions
            case .orthogonalScrollingBehavior:

                let supportedValues: [UICollectionLayoutSectionOrthogonalScrollingBehavior] = [.none,
                                                                                               .continuous,
                                                                                               .continuousGroupLeadingBoundary,
                                                                                               .paging,
                                                                                               .groupPaging,
                                                                                               .groupPagingCentered]
                let supportedValuesDisplay: [String] =  ["None", "Continuous",
                                                         "Continuous Group Leading Boundary",
                                                         "Paging",
                                                         "Group Paging",
                                                         "Group Paging Centered"]
                var actions: [UIAction] = []
                for (index, value) in supportedValues.enumerated() {
                    let identifier: String  = option.rawValue + String(describing: value)
                    let title: String = supportedValuesDisplay[index]
                    let action: UIAction = UIAction(title: title, image: nil, identifier: .init(identifier), handler: { [self] _ in
                        updateValue(value: value)
                    })
                    actions.append(action)
                }

                allActions[option] = actions
            case .layoutSize:

                var actions: [UIMenu] = []

                for direction in LayoutDirection.allCases {
                    var children: [UIMenuElement] = []
                    for dimension in LayoutDimension.allCases {
                        let combinationActions: [UIAction] = layoutSizeActions(dimension: dimension, direction: direction, initialIdentifier: option.rawValue)
                        let innerMenu: UIMenu = UIMenu(title: dimension.rawValue, identifier: .init(option.rawValue + dimension.rawValue), children: combinationActions)
                        children.append(innerMenu)
                    }

                    let mainMenu: UIMenu = UIMenu(title: direction.rawValue, identifier: .init(option.rawValue + direction.rawValue), children: children)
                    actions.append(mainMenu)
                }

                allActions[option] = actions
            case .edgeSpacing:
                var actions: [UIMenu] = []

                for direction in EdgeDirection.allCases {
                    var children: [UIMenuElement] = []
                    for dimension in Dimension.allCases {
                        let combinationActions: [UIAction] = edgeSpacingActions(dimension: dimension, direction: direction, initialIdentifier: option.rawValue)
                        let innerMenu: UIMenu = UIMenu(title: dimension.rawValue, identifier: .init(option.rawValue + dimension.rawValue), children: combinationActions)
                        children.append(innerMenu)
                    }

                    let mainMenu: UIMenu = UIMenu(title: direction.rawValue, identifier: .init(option.rawValue + direction.rawValue), children: children)
                    actions.append(mainMenu)
                }

                allActions[option] = actions

            case .layoutSpacing:

                var actions: [UIMenu] = []
                do {

                    for dimension in Dimension.allCases {
                        let combinationActions: [UIAction] = layoutSpacingActions(dimension: dimension, initialIdentifier: option.rawValue)
                        let innerMenu: UIMenu = UIMenu(title: dimension.rawValue, identifier: .init(option.rawValue + dimension.rawValue), children: combinationActions)
                        actions.append(innerMenu)
                    }
                }

                allActions[option] = actions
            case .count:

                let supportedValues: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                let actions: [UIAction] = intActions(values: supportedValues, initialIdentifier: option.rawValue)
                allActions[option] = actions
            case .addNewItem:

                var actions: [UIAction] = []
                for value in ItemType.allCases {
                    let identifier: String = option.rawValue + String(describing: value)
                    let title: String = "\(value.rawValue)"
                    let action: UIAction = UIAction(title: title, image: nil, identifier: .init(identifier), handler: { [self] _ in
                        updateValue(value: value)
                    })
                    actions.append(action)
                }

                allActions[option] = actions
            case .removeItem:

                let identifier: String = option.rawValue + "Remove Item"
                let title: String = "Remove Item"
                let action: UIAction = UIAction(title: title, image: nil, identifier: .init(identifier), attributes: .destructive, handler: { [self] _ in
                    updateValue(value: EditingAction.removeItem)
                })

                allActions[option] = [action]
            }
        }

        let childrens: [UIMenuElement] = allActions.flatMap({ (_: EditingAction, actions: [UIMenuElement]) in
            return actions
        })

        self.optionMenu = UIMenu(title: "", image: nil, identifier: .init(rawValue: "Option"), options: .displayInline, children: childrens)
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = self.optionMenu
    }

    private func layoutSizeActions(dimension: LayoutDimension, direction: LayoutDirection, initialIdentifier: String) -> [UIAction] {

        let fractionalValues: [CGFloat] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
        let absoluteValues: [CGFloat] = [5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0, 125.0, 150.0, 175.0, 200.0, 250.0, 300.0]

        var combinationActions: [UIAction] = []

        let iteratorValues: [CGFloat]

        switch dimension {
        case .fractionalWidth, .fractionalHeight:
            iteratorValues = fractionalValues
        case .estimated, .absolute:
            iteratorValues = absoluteValues
        }

        for value in iteratorValues {
            let identifier: String = initialIdentifier + direction.rawValue + dimension.rawValue + String(describing: value)
            let title: String = "\(value)"
            let action: UIAction = UIAction(title: title, image: nil, identifier: .init(identifier), handler: { [self] _ in

                let finalValue: NSCollectionLayoutDimension
                switch dimension {
                case .fractionalWidth:
                    finalValue = NSCollectionLayoutDimension.fractionalWidth(value)
                case .fractionalHeight:
                    finalValue = NSCollectionLayoutDimension.fractionalHeight(value)
                case .estimated:
                    finalValue = NSCollectionLayoutDimension.estimated(value)
                case .absolute:
                    finalValue = NSCollectionLayoutDimension.absolute(value)
                }

                if let modelValue: NSCollectionLayoutSize = model?.value as? NSCollectionLayoutSize {

                    switch direction {
                    case .all:
                        let value: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: finalValue,
                                                                                   heightDimension: finalValue)
                        updateValue(value: value)
                    case .width:
                        let value: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: finalValue,
                                                                                   heightDimension: modelValue.heightDimension)
                        updateValue(value: value)
                    case .height:
                        let value: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: modelValue.widthDimension,
                                                                                   heightDimension: finalValue)
                        updateValue(value: value)
                    }
                }
            })
            combinationActions.append(action)
        }
        return combinationActions
    }

    private func edgeSpacingActions(dimension: Dimension, direction: EdgeDirection, initialIdentifier: String) -> [UIAction] {
        let values: [CGFloat] = [0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0, 125.0, 150.0, 175.0, 200.0, 250.0, 300.0]

        var combinationActions = [UIAction]()
        for value in values {
            let identifier: String = initialIdentifier + direction.rawValue + dimension.rawValue + String(describing: value)
            let title: String = "\(value)"
            let action: UIAction = UIAction(title: title, image: nil, identifier: .init(identifier), handler: { [self] _ in

                let spacing: NSCollectionLayoutSpacing
                switch dimension {
                case .fixed:
                    spacing = NSCollectionLayoutSpacing.fixed(value)
                case .flexible:
                    spacing = NSCollectionLayoutSpacing.flexible(value)
                }

                let value: NSCollectionLayoutEdgeSpacing

                switch direction {
                case .all:
                    value = NSCollectionLayoutEdgeSpacing(leading: spacing, top: spacing, trailing: spacing, bottom: spacing)
                    updateValue(value: value)
                case .leading:
                    if let mainValue = model?.value as? NSCollectionLayoutEdgeSpacing {
                        let value = NSCollectionLayoutEdgeSpacing(leading: spacing, top: mainValue.top, trailing: mainValue.trailing, bottom: mainValue.bottom)
                        updateValue(value: value)
                    }
                case .top:
                    if let mainValue = model?.value as? NSCollectionLayoutEdgeSpacing {
                        let value = NSCollectionLayoutEdgeSpacing(leading: mainValue.leading, top: spacing, trailing: mainValue.trailing, bottom: mainValue.bottom)
                        updateValue(value: value)
                    }
                case .trailing:
                    if let mainValue = model?.value as? NSCollectionLayoutEdgeSpacing {
                        let value = NSCollectionLayoutEdgeSpacing(leading: mainValue.leading, top: mainValue.top, trailing: spacing, bottom: mainValue.bottom)
                        updateValue(value: value)
                    }
                case .bottom:
                    if let mainValue = model?.value as? NSCollectionLayoutEdgeSpacing {
                        let value = NSCollectionLayoutEdgeSpacing(leading: mainValue.leading, top: mainValue.top, trailing: mainValue.trailing, bottom: spacing)
                        updateValue(value: value)
                    }
                }
            })
            combinationActions.append(action)
        }
        return combinationActions
    }

    private func layoutSpacingActions(dimension: Dimension, initialIdentifier: String) -> [UIAction] {

        let values: [CGFloat] = [0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0, 125.0, 150.0, 175.0, 200.0, 250.0, 300.0]

        var combinationActions = [UIAction]()
        for value in values {
            let identifier: String = initialIdentifier + String(describing: value)
            let title: String = "\(value)"
            let action: UIAction = UIAction(title: title, image: nil, identifier: .init(identifier), handler: { [self] _ in

                let spacing: NSCollectionLayoutSpacing
                switch dimension {
                case .fixed:
                    spacing = NSCollectionLayoutSpacing.fixed(value)
                case .flexible:
                    spacing = NSCollectionLayoutSpacing.flexible(value)
                }
                updateValue(value: spacing)
            })
            combinationActions.append(action)
        }
        return combinationActions
    }

    private func intActions(values: [Int], initialIdentifier: String) -> [UIAction] {
        var actions: [UIAction] = []
        for value in values {
            let identifier: String = initialIdentifier + String(describing: value)
            let title: String  = "\(value)"
            let action: UIAction = UIAction(title: title, image: nil, identifier: .init(identifier), handler: { [self] _ in
                updateValue(value: value)
            })
            actions.append(action)
        }
        return actions
    }

    private func floatActions(values: [CGFloat], initialIdentifier: String) -> [UIAction] {
        var actions: [UIAction] = []
        for value in values {
            let identifier: String = initialIdentifier + String(describing: value)
            let title: String  = "\(value)"
            let action: UIAction = UIAction(title: title, image: nil, identifier: .init(identifier), handler: { [self] _ in
                updateValue(value: value)
            })
            actions.append(action)
        }
        return actions
    }
}

@available(iOS 14.0, *)
extension CustomLayoutCell {

    enum EditingAction: String, CaseIterable, Hashable {
        case scrollDirection
        case floatValue
        case directionalEdgeInsets
        case orthogonalScrollingBehavior
        case layoutSize
        case edgeSpacing
        case layoutSpacing
        case count
        case addNewItem
        case removeItem
    }
}
// swiftlint:enable file_length
