//
//  IQSection.swift
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

// MARK: - Section model of the table/collection

public struct IQSection: Hashable {

    public static func == (lhs: IQSection, rhs: IQSection) -> Bool {
        return lhs.identifier == rhs.identifier &&
        lhs.header == rhs.header &&
        lhs.headerSize == rhs.headerSize &&
        lhs.footer == rhs.footer &&
        lhs.footerSize == rhs.footerSize
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    /// Unique identifier of the section
    public var identifier: AnyHashable

    /// Header text and size
    public var header: String?
    public var headerView: UIView?
    public var headerSize: CGSize?

    /// Footer text and size
    public var footer: String?
    public var footerView: UIView?
    public var footerSize: CGSize?

    /// Initialization
    /// - Parameters:
    ///   - identifier: section identifier
    ///   - header: header text to display
    ///   - headerSize: header size
    ///   - footer: footer text to display
    ///   - footerSize: footer size
    public init(identifier: AnyHashable,
                header: String? = nil, headerView: UIView? = nil, headerSize: CGSize? = nil,
                footer: String? = nil, footerView: UIView? = nil, footerSize: CGSize? = nil) {
        self.identifier = identifier
        self.header = header
        self.footer = footer
        self.headerView = headerView
        self.footerView = footerView
        self.headerSize = headerSize
        self.footerSize = footerSize
    }
}
