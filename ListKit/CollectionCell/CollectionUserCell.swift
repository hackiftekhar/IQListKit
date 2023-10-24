//
//  CollectionUserCell.swift
//  ListKit
//
//  Created by iftekhar on 12/05/21.
//

import UIKit
import IQListKit

protocol CollectionUserCellDelegate: AnyObject {
    func userCell(_ cell: CollectionUserCell, didDelete item: User)
}

class CollectionUserCell: UICollectionViewCell, IQModelableCell {

    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var detailTextLabel: UILabel!

    weak var delegate: CollectionUserCellDelegate?

    // Or if we would like to use User as a model directly then
    // instead of implementing a struct, this can also be written as
//    typealias Model = User
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

    static func size(for model: Model, listView: IQListView) -> CGSize? {
        return CGSize(width: 150, height: 62)
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
