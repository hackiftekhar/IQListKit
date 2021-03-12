//
//  IQContextualAction.swift
//  https://github.com/hackiftekhar/IQListKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

public final class IQContextualAction: NSObject {

    public typealias Handler = (IQContextualAction, @escaping (Bool) -> Void) -> Void

    public init(style: IQContextualAction.Style, title: String?, handler: @escaping IQContextualAction.Handler) {
        self.style = style
        self.title = title
        self.handler = handler
        super.init()
    }

    public private(set) var style: IQContextualAction.Style

    public var title: String?

    public private(set) var handler: IQContextualAction.Handler

    public var backgroundColor: UIColor? /// a default background color is set from the action style

    public var image: UIImage?

    public enum Style: Int {

        case normal = 0

        case destructive = 1

        @available(iOS 11.0, *)
        var contextualStyle: UIContextualAction.Style {
            switch self {
            case .normal:       return .normal
            case .destructive:   return .destructive
            }
        }

        var rowStyle: UITableViewRowAction.Style {
            switch self {
            case .normal:       return .normal
            case .destructive:  return .destructive
            }
        }
    }

    @available(iOS 11.0, *)
    func contextualAction() -> UIContextualAction {

        let action = UIContextualAction(style: style.contextualStyle,
                                        title: title) { (_, _, completion) in
            self.handler(self, completion)
        }

        if let backgroundColor = backgroundColor {
            action.backgroundColor = backgroundColor
        }
        action.image = image

        return action
    }

    func rowAction() -> UITableViewRowAction {
        let action = UITableViewRowAction(style: style.rowStyle,
                                          title: title) { (_, _) in
            let fakeCompletion: ((Bool) -> Void) = { _ in
            }

            self.handler(self, fakeCompletion)
        }

        if let backgroundColor = backgroundColor {
            action.backgroundColor = backgroundColor
        }

        return action
    }
}
