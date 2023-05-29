//
//  IQCollectionTitleSupplementaryView.swift
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

// MARK: - A supplementary view for UICollectionView

public final class IQCollectionTitleSupplementaryView: UICollectionReusableView, IQModelableSupplementaryView {

    public let textLabel = UILabel()

    public static var defaultFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    public static var defaultTextColor: UIColor?

    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 0
        textLabel.font = Self.defaultFont
        if let defaultTextColor = Self.defaultTextColor {
            textLabel.textColor = defaultTextColor
        } else {
            textLabel.textColor = UIColor.label
        }
        addSubview(textLabel)

        let views: [String: UIView] = ["textLabel": textLabel]

        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[textLabel]-20-|",
                                                          options: [], metrics: [:], views: views)
        let centerY = NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal,
                                         toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        addConstraints(hConstraints)
        addConstraint(centerY)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public typealias Model = String

    public var model: Model? {
        didSet {
            textLabel.text = model
        }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        textLabel.text = nil
        textLabel.setNeedsLayout()
    }

    public static func size(for model: AnyHashable?, listView: IQListView) -> CGSize {
        if let model = model as? Model {
            let string = NSString(string: model)
            let attributes: [NSAttributedString.Key: Any] = [.font: defaultFont]

            let boundingSize = CGSize(width: listView.frame.width - 20 - 20,
                                      height: CGFloat.greatestFiniteMagnitude)
            let expectedTextSize = string.boundingRect(with: boundingSize,
                                                       options: .usesLineFragmentOrigin,
                                                       attributes: attributes, context: nil).size
            return CGSize(width: listView.frame.width, height: expectedTextSize.height + 5 + 5)
        }
        return CGSize(width: listView.frame.width, height: 22)
    }
}
