//
//  IQNoItemStateView.swift
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

/// InfoView to show in the middle of the list when the list is noItem
public final class IQNoItemStateView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        do {
            self.addSubview(loadingStackView)
            loadingStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            loadingStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            loadingStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            loadingStackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true

            loadingStackView.addArrangedSubview(loadingIndicator)
            loadingStackView.addArrangedSubview(loadingMessageLabel)
        }

        do {
            self.addSubview(noItemStackView)
            noItemStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            noItemStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            noItemStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            noItemStackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true

            noItemStackView.addArrangedSubview(noItemImageView)
            noItemStackView.addArrangedSubview(noItemTitleLabel)
            noItemStackView.addArrangedSubview(noItemMessageLabel)
            noItemStackView.addArrangedSubview(noItemActionButton)
        }
    }

    convenience init(noItemImage: UIImage? = nil,
                     noItemTitle: String?,
                     noItemMessage: String? = nil,
                     loadingMessage: String? = nil) {

        defer {
            self.noItemImage = noItemImage
            self.noItemTitle = noItemTitle
            self.noItemMessage = noItemMessage
            self.loadingMessage = loadingMessage
        }

        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal private(set) var isLoading: Bool = false

    internal func setIsLoading(_ isLoading: Bool,
                               haveRecords: Bool,
                               animated: Bool = false) {
        self.isLoading = isLoading

        let animationDuration = animated ? 0.3 : 0
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            if isLoading {
                self?.loadingIndicator.startAnimating()
            } else {
                self?.loadingIndicator.stopAnimating()
            }

            self?.loadingStackView.alpha = isLoading ? 1.0 : 0.0
            self?.noItemStackView.alpha = (!isLoading && !haveRecords) ? 1.0 : 0.0
        }, completion: {  [weak self] success in
            if success, !isLoading, haveRecords {
                self?.removeFromSuperview()
            }
        })
    }

    public var noItemImage: UIImage? {
        get {   noItemImageView.image }
        set {
            noItemImageView.image = newValue
            noItemImageView.isHidden = newValue == nil
        }
    }

    public var noItemTitle: String? {
        get {   noItemTitleLabel.text }
        set {
            noItemTitleLabel.text = newValue
            noItemTitleLabel.isHidden = newValue == nil
        }
    }

    public var noItemMessage: String? {
        get {   noItemMessageLabel.text }
        set {
            noItemMessageLabel.text = newValue
            noItemMessageLabel.isHidden = newValue == nil
        }
    }

    public var loadingMessage: String? {
        get {   loadingMessageLabel.text }
        set {
            loadingMessageLabel.text = newValue
            loadingMessageLabel.isHidden = newValue == nil
        }
    }

    private let noItemStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alpha = 0.0
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public let noItemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    public let noItemTitleLabel: UILabel = {
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

    public let noItemMessageLabel: UILabel = {
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

    public let noItemActionButton: UIButton = {
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

    public func action(title: String?, target: Any?, action: Selector) {
        noItemActionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let title = title, let target = target {
            noItemActionButton.setTitle(title, for: .normal)
            noItemActionButton.addTarget(target, action: action, for: .touchUpInside)
            noItemActionButton.isHidden = false
        } else {
            noItemActionButton.setTitle(nil, for: .normal)
            noItemActionButton.isHidden = true
        }
    }

    /// Will display in the middle if isLoading is true
    private let loadingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alpha = 0.0
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public let loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(style: .gray)
        loadingIndicator.hidesWhenStopped = false
        return loadingIndicator
    }()

    public let loadingMessageLabel: UILabel = {
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
}
