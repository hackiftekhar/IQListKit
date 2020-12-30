//
//  IQTableViewCell.swift
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

// MARK: Basic implementation of IQModelableCell

public class IQTableViewCell: UITableViewCell, IQModelableCell {

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //Model property
    public var model: Model? {
        didSet {
            textLabel?.text = model?.text
            detailTextLabel?.text = model?.detail
            accessoryType = model?.accessoryType ?? .none
        }
    }

    //Model associated type for this class
    public struct Model: Hashable {

        public func hash(into hasher: inout Hasher) {
            hasher.combine(text)
            hasher.combine(detail)
            hasher.combine(accessoryType)
        }

        public static func == (lhs: Model, rhs: Model) -> Bool {
            return lhs.text == rhs.text && lhs.detail == rhs.detail && rhs.accessoryType == lhs.accessoryType
        }

        public init(text: String? = nil, detail: String? = nil,
                    accessoryType: UITableViewCell.AccessoryType? = nil, attributes: Any? = nil) {
            self.text = text
            self.detail = detail
            self.accessoryType = accessoryType
            self.attributes = attributes
        }

        let text: String?
        let detail: String?
        let accessoryType: UITableViewCell.AccessoryType?
        let attributes: Any?
    }
}
