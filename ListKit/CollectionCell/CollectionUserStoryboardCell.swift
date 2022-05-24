//
//  CollectionUserStoryboardCell.swift
//  ListKit
//
//  Created by Iftekhar on 24/05/22.
//

import Foundation

import UIKit
import IQListKit

protocol CollectionUserStoryboardCellDelegate: AnyObject {
    func userCell(_ cell: CollectionUserStoryboardCell, didDelete item: User)
}

class CollectionUserStoryboardCell: UICollectionViewCell, IQModelableCell {

    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var detailTextLabel: UILabel!

    weak var delegate: CollectionUserStoryboardCellDelegate?

    // Or if we would like to use User as a model directly then
    // instead of implementing a struct, this can also be written as
//    typealias Model = User

    var model: User? {
        didSet {
            guard let model = model else {
                return
            }

            textLabel.text = model.name
            detailTextLabel.text = model.email
        }
    }

    static func size(for model: AnyHashable?, listView: IQListView) -> CGSize {
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
