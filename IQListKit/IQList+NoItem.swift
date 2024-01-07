//
//  IQList+NoItem.swift
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

import Foundation

@MainActor
extension IQList {

    public var noItemImage: UIImage? {
        get {   noItemStateView?.noItemImage    }
        set {   noItemStateView?.noItemImage = newValue  }
    }

    public var noItemTitle: String? {
        get {   noItemStateView?.noItemTitle    }
        set {   noItemStateView?.noItemTitle = newValue  }
    }

    public var noItemMessage: String? {
        get {   noItemStateView?.noItemMessage    }
        set {   noItemStateView?.noItemMessage = newValue  }
    }

    public var loadingMessage: String? {
        get {   noItemStateView?.loadingMessage    }
        set {   noItemStateView?.loadingMessage = newValue  }
    }

    public func noItemAction(title: String?, target: Any?, action: Selector) {
        noItemStateView?.action(title: title, target: target, action: action)
    }

    internal func noItemStateViewChanged() {

        if let noItemStateView = noItemStateView {
            noItemStateView.removeFromSuperview()   // This is necessary to remove old constraints
            noItemContainerView.addSubview(noItemStateView)
            if noItemStateView.translatesAutoresizingMaskIntoConstraints {
                noItemStateView.center = CGPoint(x: noItemContainerView.bounds.midX,
                                                 y: noItemContainerView.bounds.midY)
                noItemStateView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin,
                                                    .flexibleLeftMargin, .flexibleRightMargin]
            } else {
                noItemStateView.leadingAnchor.constraint(greaterThanOrEqualTo: noItemContainerView.leadingAnchor,
                                                         constant: 20)
                .isActive = true
                noItemStateView.trailingAnchor.constraint(lessThanOrEqualTo: noItemContainerView.trailingAnchor,
                                                          constant: 20)
                .isActive = true
                noItemStateView.topAnchor.constraint(greaterThanOrEqualTo: noItemContainerView.topAnchor,
                                                     constant: 20)
                .isActive = true
                noItemStateView.bottomAnchor.constraint(lessThanOrEqualTo: noItemContainerView.bottomAnchor,
                                                        constant: 20)
                .isActive = true
            }
        }
    }

    internal func updateNoItemStateViewPosition() {
        noItemContainerView.removeFromSuperview()   // This is necessary to remove old constraints
        listView.insertSubview(noItemContainerView, at: 0)
        noItemContainerView.translatesAutoresizingMaskIntoConstraints = false

        let inset: UIEdgeInsets = listView.adjustedContentInset
        noItemContainerView.leadingAnchor.constraint(equalTo: listView.frameLayoutGuide.leadingAnchor)
            .isActive = true
        noItemContainerView.trailingAnchor.constraint(equalTo: listView.frameLayoutGuide.trailingAnchor)
            .isActive = true
        noItemContainerView.topAnchor.constraint(equalTo: listView.topAnchor).isActive = true
        let height = listView.frame.height - inset.top - inset.bottom
        noItemContainerView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
