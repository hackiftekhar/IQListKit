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
public struct IQSection: Hashable, @unchecked Sendable {

    public static func == (lhs: IQSection, rhs: IQSection) -> Bool {

//      #if targetEnvironment(simulator)
//        if Thread.isMainThread {
//            print("Diffing \(lhs.identifier) on Main Thread")
//        }
//      #endif

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
    public private(set) var headerType: (any IQModelableSupplementaryView.Type)?
    public private(set) var footerType: (any IQModelableSupplementaryView.Type)?

    /// Header/Footer
    public private(set) var headerView: UIView?
    public private(set) var headerSize: CGSize?
    public private(set) var footerView: UIView?
    public private(set) var footerSize: CGSize?

    /// Model of the cell
    public private(set) var headerModel: AnyHashable?
    public private(set) var footerModel: AnyHashable?

    public init<H: IQModelableSupplementaryView,
                F: IQModelableSupplementaryView>(identifier: AnyHashable,
                                                 headerType: H.Type, headerModel: H.Model,
                                                 footerType: F.Type, footerModel: F.Model) {
        self.identifier = identifier
        self.headerType = headerType
        self.headerModel = headerModel
        self.footerType = footerType
        self.footerModel = footerModel
    }

    public init<H: IQModelableSupplementaryView>(identifier: AnyHashable,
                                                 headerType: H.Type, headerModel: H.Model,
                                                 footer: String? = nil, footerSize: CGSize? = nil) {
        self.identifier = identifier

        self.headerType = headerType
        self.headerModel = headerModel

        if let footer = footer {
            footerType = IQSupplementaryViewPlaceholder.self
            footerModel = footer
        }
    }

    public init<F: IQModelableSupplementaryView>(identifier: AnyHashable,
                                                 header: String? = nil, headerSize: CGSize? = nil,
                                                 footerType: F.Type, footerModel: F.Model) {
        self.identifier = identifier

        if let header = header {
            headerType = IQSupplementaryViewPlaceholder.self
            headerModel = header
        }
        self.headerSize = headerSize

        self.footerType = footerType
        self.footerModel = footerModel
    }

    /// Initialization
    /// - Parameters:
    ///   - identifier: section identifier
    ///   - header: header text to display
    ///   - headerSize: header size
    ///   - footer: footer text to display
    ///   - footerSize: footer size
    public init(identifier: AnyHashable,
                header: String? = nil, headerSize: CGSize? = nil,
                footer: String? = nil, footerSize: CGSize? = nil) {
        self.identifier = identifier

        if let header = header {
            headerType = IQSupplementaryViewPlaceholder.self
            headerModel = header
        }
        self.headerSize = headerSize

        if let footer = footer {
            footerType = IQSupplementaryViewPlaceholder.self
            footerModel = footer
        }
        self.footerSize = footerSize
    }
}

extension IQSection {

    @available(*, deprecated, message: "Using headerView or footerView is deprecated.",
                renamed: "init(identifier:header:headerSize:footer:footerSize:)")
    public init(identifier: AnyHashable,
                header: String? = nil, headerView: UIView? = nil, headerSize: CGSize? = nil,
                footer: String? = nil, footerView: UIView? = nil, footerSize: CGSize? = nil) {
        self.identifier = identifier
        if let headerView = headerView {
            self.headerView = headerView
        } else if let header = header {
            headerType = IQSupplementaryViewPlaceholder.self
            headerModel = header
        }
        self.headerSize = headerSize

        if let footerView = footerView {
            self.footerView = footerView
        } else if let footer = footer {
            footerType = IQSupplementaryViewPlaceholder.self
            footerModel = footer
        }
        self.footerSize = footerSize
    }

    @available(*, deprecated, message: "Using footerView is deprecated.",
                renamed: "init(identifier:headerType:headerModel:footer:footerSize:)")
    public init<H: IQModelableSupplementaryView>(identifier: AnyHashable,
                                                 headerType: H.Type, headerModel: H.Model,
                                                 footer: String? = nil, footerView: UIView? = nil,
                                                 footerSize: CGSize? = nil) {
        self.identifier = identifier
        self.headerType = headerType
        self.headerModel = headerModel
        if let footerView = footerView {
            self.footerView = footerView
        } else if let footer = footer {
            footerType = IQSupplementaryViewPlaceholder.self
            footerModel = footer
        }
        self.footerSize = footerSize
    }

    @available(*, deprecated, message: "Using headerView is deprecated.",
                renamed: "init(identifier:header:headerSize:footerType:footerModel:)")
    public init<F: IQModelableSupplementaryView>(identifier: AnyHashable,
                                                 header: String? = nil, headerView: UIView? = nil,
                                                 headerSize: CGSize? = nil,
                                                 footerType: F.Type, footerModel: F.Model) {
        self.identifier = identifier
        if let headerView = headerView {
            self.headerView = headerView
        } else if let header = header {
            headerType = IQSupplementaryViewPlaceholder.self
            headerModel = header
        }
        self.headerSize = headerSize

        self.footerType = footerType
        self.footerModel = footerModel
    }
}
