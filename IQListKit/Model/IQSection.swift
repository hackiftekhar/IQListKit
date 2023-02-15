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
        lhs.headerType == rhs.headerType &&
        lhs.footerType == rhs.footerType &&
        lhs.headerModel == rhs.headerModel &&
        lhs.footerModel == rhs.footerModel
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    /// Unique identifier of the section
    public let identifier: AnyHashable

    /// Type of the cell
    public private(set) var headerType: IQListSupplementaryView.Type?
    public private(set) var footerType: IQListSupplementaryView.Type?

    /// Model of the cell
    public private(set) var headerModel: AnyHashable?
    public private(set) var footerModel: AnyHashable?

    /// Initialization
    /// - Parameters:
    ///   - identifier: section identifier
    ///   - header: header text to display
    ///   - headerSize: header size
    ///   - footer: footer text to display
    ///   - footerSize: footer size
    public init(identifier: AnyHashable,
                header: String? = nil,
                footer: String? = nil) {
        self.identifier = identifier
        if let header = header {
            self.headerType = IQSupplementaryViewPlaceholder.self
            self.headerModel = header
        }

        if let footer = footer {
            self.footerType = IQSupplementaryViewPlaceholder.self
            self.footerModel = footer
        }
    }

    public init<H: IQModelableSupplementaryView>(identifier: AnyHashable,
                                                 headerType: H.Type, headerModel: H.Model) {
        // swiftlint:enable line_length
        self.identifier = identifier
        self.headerType = headerType
        self.headerModel = headerModel
        self.footerType = IQSupplementaryViewPlaceholder.self
        self.footerModel = nil
    }

    public init<F: IQModelableSupplementaryView>(identifier: AnyHashable,
                                                 footerType: F.Type, footerModel: F.Model) {
        // swiftlint:enable line_length
        self.identifier = identifier
        self.headerType = IQSupplementaryViewPlaceholder.self
        self.headerModel = nil
        self.footerType = footerType
        self.footerModel = footerModel
    }

    public init<H: IQModelableSupplementaryView,
                F: IQModelableSupplementaryView>(identifier: AnyHashable,
                                                 headerType: H.Type, headerModel: H.Model,
                                                 footerType: F.Type, footerModel: F.Model) {
        // swiftlint:enable line_length
        self.identifier = identifier
        self.headerType = headerType
        self.headerModel = headerModel
        self.footerType = footerType
        self.footerModel = footerModel
    }
}
