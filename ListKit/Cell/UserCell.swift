//
//  UserCell.swift
//
//  Created by Iftekhar on 11/12/20.
//

import UIKit
import IQListKit

protocol UserCellDelegate: class {
    func userCell(_ cell: UserCell, didDelete item: User)
}

class UserCell: UITableViewCell, IQModelableCell {

    weak var delegate: UserCellDelegate?

    struct Model: Hashable {
        let user: User?
        let people: People?
    }
    //Or if we would like to use User as a model directly then
    // instead of implementing a struct, this can also be written as
//    typealias Model = User

    var model: Model? {
        didSet {
            guard let model = model else {
                return
            }

            if let user = model.user {
                textLabel?.text = user.name
            } else if let people = model.people {
                textLabel?.text = people.name
            }

            detailTextLabel?.text = "Loaded using XIB"

//            textLabel?.text = model.name
//            detailTextLabel?.text = model.email
        }
    }

//    static func size(for model: AnyHashable?, listView: IQListView) -> CGSize {
//        if let model = model as? Model {
//            if model.user.name == "First" {
//                return CGSize(width: listView.frame.width, height: 100)
//            } else {
//                return CGSize(width: listView.frame.width, height: 50)
//            }
//        }
//        return CGSize(width: listView.frame.width, height: UITableView.automaticDimension)
//    }

//    var isHighlightable: Bool {
//        return true
//    }
//
//    var isSelectable: Bool {
//        return false
//    }

    func leadingSwipeActions() -> [UIContextualAction]? {
        let action = UIContextualAction(style: .normal, title: "Hello Leading") { (_, _, completionHandler) in
            completionHandler(true)
        }
        action.backgroundColor = UIColor.orange

        return [action]
    }

    func trailingSwipeActions() -> [UIContextualAction]? {

        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            completionHandler(true)
            guard let self = self, let user = self.model?.user else {
                return
            }
            self.delegate?.userCell(self, didDelete: user)
        }

        return [action]
    }

    func contextMenuConfiguration() -> UIContextMenuConfiguration? {

        let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil,
                                                                  previewProvider: { () -> UIViewController? in
            let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(identifier: "UserViewController") as? UserViewController
            controller?.user = self.model?.user
            return controller
        }, actionProvider: { (actions) -> UIMenu? in

            var actions = [UIMenuElement]()
            let save = UIAction(title: "Save in Photos") { _ in
            }
            actions.append(save)

            let open = UIAction(title: "Open in Browser") { _ in
            }
            actions.append(open)

            let mixed = UIAction(title: "Nothing") { _ in
            }
            actions.append(mixed)

            do {
                var nestedActions = [UIMenuElement]()
                let save = UIAction(title: "Nested 1", attributes: .disabled) { _ in
                }
                nestedActions.append(save)

                let open = UIAction(title: "Nested 2", attributes: .destructive) { _ in
                }
                nestedActions.append(open)

                let nestedMenu = UIMenu(title: "Nested Menu", options: [], children: nestedActions)
                actions.append(nestedMenu)
            }

            return UIMenu(title: "Nested Menu", children: actions)
        })

        return contextMenuConfiguration
    }

//    func contextMenuPreviewView(configuration: UIContextMenuConfiguration) -> UIView? {
//        return detailTextLabel
//    }

    func performPreviewAction(configuration: UIContextMenuConfiguration,
                              animator: UIContextMenuInteractionCommitAnimating) {
        if let previewViewController = animator.previewViewController, let parent = viewParentController {
            animator.addAnimations {
                (parent.navigationController ?? parent).show(previewViewController, sender: self)
            }
        }
    }
}

private extension UIView {
    var viewParentController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let next = parentResponder?.next {
            if let viewController = next as? UIViewController {
                return viewController
            } else {  parentResponder = next  }
        }
        return nil
    }
}
