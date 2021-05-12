//
//  IQTableViewHeaderFooterView.swift
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

// MARK: - A header footer view for UITableView

public class IQTableViewHeaderFooterView: UITableViewHeaderFooterView {

    public let titleLabel = UILabel()

    public static var defaultFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    public static var defaultTextColor: UIColor?

    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        titleLabel.text = nil
        titleLabel.setNeedsLayout()
    }

    private func setup() {

        titleLabel.font = Self.defaultFont
        if let defaultTextColor = Self.defaultTextColor {
            titleLabel.textColor = defaultTextColor
        } else if #available(iOS 13.0, *) {
            titleLabel.textColor = UIColor.label
        } else {
            titleLabel.textColor = UIColor.darkText
        }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        self.contentView.addSubview(titleLabel)
        let views: [String: UIView] = ["headerFooterView": self, "titleLabel": titleLabel]

        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLabel]-10-|",
                                                          options: [], metrics: [:], views: views)
        let centerY = NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal,
                                         toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraints(hConstraints)
        self.addConstraint(centerY)
    }

    static func sizeThatFitText(text: String?, tableView: UITableView) -> CGSize {
        if let text = text {
            let string = NSString(string: text)
            let attributes: [NSAttributedString.Key: Any] = [.font: defaultFont]

            let boundingSize = CGSize(width: tableView.frame.width - 10 - 10, height: CGFloat.greatestFiniteMagnitude)
            let expectedTextSize = string.boundingRect(with: boundingSize,
                                                       options: .usesLineFragmentOrigin,
                                                       attributes: attributes, context: nil).size
            return CGSize(width: tableView.frame.width, height: expectedTextSize.height + 5 + 5)
        }
        return CGSize(width: tableView.frame.width, height: 22)
    }
}
