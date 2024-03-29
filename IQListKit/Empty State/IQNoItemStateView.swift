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
@MainActor
public final class IQNoItemStateView: UIView, IQNoItemStateRepresentable {

    override init(frame: CGRect) {
        super.init(frame: frame)

        do {
            addSubview(loadingStackView)
            loadingStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            loadingStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            loadingStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            loadingStackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true

            loadingStackView.addArrangedSubview(loadingIndicator)
            loadingStackView.addArrangedSubview(loadingMessageLabel)
        }

        do {
            addSubview(noItemStackView)
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

    public func setIsLoading(_ isLoading: Bool,
                             haveRecords: Bool,
                             animated: Bool = false) {
        if isLoading {
            noItemStackView.alpha = 0.0

            if haveRecords {
                loadingIndicator.stopAnimating()
                loadingStackView.alpha = 0.0
            } else {
                loadingIndicator.startAnimating()
                loadingStackView.alpha = 1.0
            }
        } else {
            loadingIndicator.stopAnimating()
            loadingStackView.alpha = 0.0
            noItemStackView.alpha = haveRecords ? 0.0 : 1.0
        }
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
        label.textColor = UIColor.label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let noItemMessageLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        label.textColor = UIColor.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let noItemActionButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
        button.setTitleColor(.link, for: .normal)
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
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.hidesWhenStopped = false
        return loadingIndicator
    }()

    public let loadingMessageLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        label.textColor = UIColor.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}
