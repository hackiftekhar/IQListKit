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

    static func estimatedSize(for model: AnyHashable?, listView: IQListView) -> CGSize {
        return CGSize(width: listView.frame.width, height: 100)
    }

    static func size(for model: AnyHashable?, listView: IQListView) -> CGSize {

        if let model = model as? Model {
            var height: CGFloat = 100
            //....
            // return height based on the model
            return CGSize(width: listView.frame.width, height: height)
        }

        //Or return a constant height
        return CGSize(width: listView.frame.width, height: 100)

        //Or UITableView.automaticDimension for dynamic behaviour
//        return CGSize(width: listView.frame.width, height: UITableView.automaticDimension)
    }

    var isHighlightable: Bool {
        return true
    }

    var isSelectable: Bool {
        return false
    }

    @available(iOS 11.0, *)
    func leadingSwipeActions() -> [IQContextualAction]? {
        let action = IQContextualAction(style: .normal, title: "Hello Leading") { (action, completionHandler) in
            completionHandler(true)
        }
        action.backgroundColor = UIColor.orange

        return [action]
    }

    func trailingSwipeActions() -> [IQContextualAction]? {

        let action1 = IQContextualAction(style: .normal, title: "Hello Trailing") { [weak self] (action, completionHandler) in
            completionHandler(true)
            guard let self = self, let user = self.model else {
                return
            }

            //Do your stuffs here
        }

        action.backgroundColor = UIColor.purple

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

    @available(iOS 13.0, *)
    func contextMenuPreviewView(configuration: UIContextMenuConfiguration) -> UIView? {
        return detailTextLabel
    }

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
