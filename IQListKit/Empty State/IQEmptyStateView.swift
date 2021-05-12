//
//  IQEmptyStateView.swift
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

/// InfoView to show in the middle of the list when the list is empty
public final class IQEmptyStateView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(actionButton)
    }

    convenience init(image: UIImage? = nil, title: String?, message: String? = nil) {

        defer {
            self.image = image
            self.title = title
            self.message = message
        }

        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var image: UIImage? {
        get {   imageView.image }
        set {
            imageView.image = newValue
            imageView.isHidden = newValue == nil
        }
    }

    public var title: String? {
        get {   titleLabel.text }
        set {
            titleLabel.text = newValue
            titleLabel.isHidden = newValue == nil
        }
    }

    public var message: String? {
        get {   messageLabel.text }
        set {
            messageLabel.text = newValue
            messageLabel.isHidden = newValue == nil
        }
    }

    public func action(title: String?, target: Any?, action: Selector) {
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let title = title, let target = target {
            actionButton.setTitle(title, for: .normal)
            actionButton.addTarget(target, action: action, for: .touchUpInside)
            actionButton.isHidden = false
        } else {
            actionButton.setTitle(nil, for: .normal)
            actionButton.isHidden = true
        }
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        if #available(iOS 13.0, *) {
            label.textColor = UIColor.label
        } else {
            label.textColor = UIColor.darkText
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let messageLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        if #available(iOS 13.0, *) {
            label.textColor = UIColor.secondaryLabel
        } else {
            label.textColor = UIColor.gray
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
        if #available(iOS 13.0, *) {
            button.setTitleColor(.link, for: .normal)
        } else {
            button.setTitleColor(UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1), for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
}
