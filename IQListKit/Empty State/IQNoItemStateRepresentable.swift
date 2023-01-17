//
//  IQNoItemStateRepresentable.swift
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

public protocol IQNoItemStateRepresentable where Self: UIView {

    var noItemImage: UIImage? { get set }

    var noItemTitle: String? { get set }

    var noItemMessage: String? { get set }

    var loadingMessage: String? { get set }

    func action(title: String?, target: Any?, action: Selector)

    func setIsLoading(_ isLoading: Bool,
                      haveRecords: Bool,
                      animated: Bool)
}

// swiftlint:disable unused_setter_value
public extension IQNoItemStateRepresentable {

    var noItemImage: UIImage? {
        get {
            return nil
        }
        set {
        }
    }

    var noItemTitle: String? {
        get {
            return nil
        }
        set {
        }
    }

    var noItemMessage: String? {
        get {
            return nil
        }
        set {
        }
    }

    var loadingMessage: String? {
        get {
            return nil
        }
        set {
        }
    }

    func action(title: String?, target: Any?, action: Selector) {
    }
}
