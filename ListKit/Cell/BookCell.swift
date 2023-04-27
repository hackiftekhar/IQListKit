//
//  BookCell.swift
//  ListKit
//
//  Created by Iftekhar on 30/12/20.
//

import UIKit
import IQListKit

protocol BookCellDelegate: AnyObject {
    func bookCell(_ cell: BookCell, didDelete item: Book)
}

class BookCell: UITableViewCell, IQModelableCell {

    weak var delegate: BookCellDelegate?

    typealias Model = Book

    var model: Model? {
        didSet {
            textLabel?.text = model?.name
            detailTextLabel?.text = "Loaded using Storyboard"
        }
    }

    func trailingSwipeActions() -> [UIContextualAction]? {

        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            completionHandler(true)
            guard let self = self, let model = self.model else {
                return
            }

            self.delegate?.bookCell(self, didDelete: model)
            // Do your stuffs here
        }

        return [action]
    }

    static func indentationLevel(for model: AnyHashable?, listView: IQListView) -> Int {
        return 4
    }
}
