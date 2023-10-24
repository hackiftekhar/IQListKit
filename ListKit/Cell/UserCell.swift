//
//  UserCell.swift
//
//  Created by Iftekhar on 11/12/20.
//

import UIKit
import IQListKit

protocol UserCellDelegate: AnyObject {
    func userCell(_ cell: UserCell, didDelete item: User)
}

class UserCell: UITableViewCell, IQModelableCell {

    weak var delegate: UserCellDelegate?

    // Or if we would like to use User as a model directly then
    // instead of implementing a struct, this can also be written as
    // typealias Model = User
    typealias Model = User
    var model: Model? {
        didSet {
            guard let model = model else {
                return
            }

            textLabel?.text = model.name
            detailTextLabel?.text = model.email
        }
    }

    static func indentationLevel(for model: Model, listView: IQListView) -> Int {
        return 2
    }

    @available(iOS 11.0, *)
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
            guard let self = self, let model = self.model else {
                return
            }

            self.delegate?.userCell(self, didDelete: model)
            // Do your stuffs here
        }

        return [action]
    }

    @available(iOS 13.0, *)
    func contextMenuConfiguration() -> UIContextMenuConfiguration? {

        let contextMenuConfiguration: UIContextMenuConfiguration = UIContextMenuConfiguration(identifier: nil,
                                                                  previewProvider: { () -> UIViewController? in
            let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(identifier: "UserViewController") as? UserViewController
            controller?.user = self.model
            return controller
        }, actionProvider: { (actions) -> UIMenu? in

            var actions: [UIMenuElement] = []
            let action: UIAction = UIAction(title: "Hello Action") { _ in
            }
            actions.append(action)

            return UIMenu(title: "Nested Menu", children: actions)
        })

        return contextMenuConfiguration
    }

//    @available(iOS 13.0, *)
//    func contextMenuPreviewView(configuration: UIContextMenuConfiguration) -> UIView? {
//        return textLabel
//    }

    @available(iOS 13.0, *)
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
