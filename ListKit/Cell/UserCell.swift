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

//    struct Model: Hashable {
//        let user: User?
//        let people: People?
//    }
    //Or if we would like to use User as a model directly then
    // instead of implementing a struct, this can also be written as
//    typealias Model = User

    var model: User? {
        didSet {
            guard let model = model else {
                return
            }

            textLabel?.text = model.name
            detailTextLabel?.text = "Loaded using XIB"
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

    @available(iOS 11.0, *)
    func leadingSwipeActions() -> [IQContextualAction]? {
        let action = IQContextualAction(style: .normal, title: "Hello Leading") { (action, completionHandler) in
            completionHandler(true)
        }
        action.backgroundColor = UIColor.orange

        return [action]
    }

    func trailingSwipeActions() -> [IQContextualAction]? {

        let action = IQContextualAction(style: .destructive, title: "Delete") { [weak self] (action, completionHandler) in
            completionHandler(true)
            guard let self = self, let user = self.model else {
                return
            }

            self.delegate?.userCell(self, didDelete: user)
            //Do your stuffs here
        }

        return [action]
    }

    @available(iOS 13.0, *)
    func contextMenuConfiguration() -> UIContextMenuConfiguration? {

        let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil,
                                                                  previewProvider: { () -> UIViewController? in
            let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(identifier: "UserViewController") as? UserViewController
            controller?.user = self.model
            return controller
        }, actionProvider: { (actions) -> UIMenu? in

            var actions = [UIMenuElement]()
            let action = UIAction(title: "Hello Action") { _ in
            }
            actions.append(action)

            return UIMenu(title: "Nested Menu", children: actions)
        })

        return contextMenuConfiguration
    }

//    func contextMenuPreviewView(configuration: UIContextMenuConfiguration) -> UIView? {
//        return detailTextLabel
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
