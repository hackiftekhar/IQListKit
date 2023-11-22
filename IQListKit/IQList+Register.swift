//
//  IQList+Register.swift
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

#if canImport(SwiftTryCatch)
import SwiftTryCatch
#endif

// MARK: - Manual cell and supplementary view registration

public extension IQList {

    enum RegisterType: Sendable {
        case `default`
        case nib
        case `class`
        case storyboard
    }

    @MainActor
    internal func register(newCells: [any IQModelableCell.Type],
                           newSupplementaryViews: [String: [any IQModelableSupplementaryView.Type]]) {
        for type in newCells {
            privateRegisterCell(type: type, registerType: .default,
                                bundle: .main, logEnabled: true)
        }

        for (kind, types) in newSupplementaryViews {
            for type in types {
                privateRegisterSupplementaryView(type: type, kind: kind,
                                                 registerType: .default, bundle: .main,
                                                 logEnabled: true)
            }
        }
    }

    /// register a Cell manually
    /// - Parameters:
    ///   - type: Type of the cell
    ///   - bundle: The bundle in which the cell is present.
    ///   - registerType: The cell registration type
    @MainActor
    func registerCell<T: IQModelableCell>(type: T.Type,
                                          registerType: RegisterType,
                                          bundle: Bundle = .main) {

        privateRegisterCell(type: type,
                            registerType: registerType,
                            bundle: bundle, logEnabled: false)
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    @MainActor
    private func privateRegisterCell<T: IQModelableCell>(type: T.Type,
                                                         registerType: RegisterType,
                                                         bundle: Bundle,
                                                         logEnabled: Bool) {

        guard registeredCells.contains(where: { $0 == type}) == false else {
            return
        }

        registeredCells.append(type)

        let identifier = String(describing: type)

        switch registerType {
        case .storyboard:
            // Manually added the entry since it's already registered
            break
        case .nib:
            privateRegisterCellNib(identifier: identifier, bundle: bundle)
        case .class:
            privateRegisterCellClass(type: type, identifier: identifier)
        case .default:

            if bundle.path(forResource: identifier, ofType: "nib") != nil {
                privateRegisterCellNib(identifier: identifier, bundle: bundle)
                if logEnabled {
                    print("""
                        Registered \
                        'list.registerCell(type: \(identifier).self, registerType: .nib)'
                        """)
                }
            } else {
                if let tableView = listView as? UITableView {
                    // Validate if the cell is configured in storyboard
                    if tableView.dequeueReusableCell(withIdentifier: identifier) != nil {
                        if logEnabled {
                            print("""
                                Registered \
                                'list.registerCell(type: \(identifier).self, registerType: .storyboard)'
                                """)
                        }
                    } else {
                        privateRegisterCellClass(type: type, identifier: identifier)
                        if logEnabled {
                            print("""
                                Registered \
                                'list.registerCell(type: \(identifier).self, registerType: .class)'
                                """)
                        }
                    }
                } else if (listView as? UICollectionView) != nil {
                    privateRegisterCellClass(type: type, identifier: identifier)
                    if logEnabled {
                        print("""
                            Registered \
                            'list.registerCell(type: \(identifier).self, registerType: .class)'. \
                            If it's registered with storyboard then manually register it using\
                            \n'list.registerCell(type: \(identifier).self, registerType: .storyboard)'
                            """)
                    }
                }
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length

    @MainActor
    private func privateRegisterCellNib(identifier: String,
                                        bundle: Bundle) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        if let tableView = listView as? UITableView {
            tableView.register(nib, forCellReuseIdentifier: identifier)
        } else if let collectionView = listView as? UICollectionView {
            collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        }
    }

    @MainActor
    private func privateRegisterCellClass<T: IQModelableCell>(type: T.Type,
                                                              identifier: String) {
        if let tableView = listView as? UITableView {
            tableView.register(type.self, forCellReuseIdentifier: identifier)
        } else if let collectionView = listView as? UICollectionView {
            collectionView.register(type.self, forCellWithReuseIdentifier: identifier)
        }
    }

    /// register a supplementary view manually
    /// - Parameters:
    ///   - type: Type of the header
    ///   - bundle: The bundle in which the header is present.
    @MainActor
    func registerSupplementaryView<T: IQModelableSupplementaryView>(type: T.Type, kind: String,
                                                                    registerType: RegisterType,
                                                                    bundle: Bundle = .main) {

        privateRegisterSupplementaryView(type: type, kind: kind,
                                         registerType: registerType,
                                         bundle: bundle, logEnabled: false)
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    @MainActor
    private func privateRegisterSupplementaryView<T: IQModelableSupplementaryView>(type: T.Type,
                                                                                   kind: String,
                                                                                   registerType: RegisterType,
                                                                                   bundle: Bundle,
                                                                                   logEnabled: Bool) {
        let existingTypes = registeredSupplementaryViews[kind] ?? []
        guard existingTypes.contains(where: {$0 == type}) == false else {
            return
        }

        var newTypes: [any IQModelableSupplementaryView.Type] = existingTypes
        newTypes.append(type)
        registeredSupplementaryViews[kind] = newTypes
        diffableDataSource.registeredSupplementaryViews = registeredSupplementaryViews

        let identifier = String(describing: type)

        switch registerType {
        case .storyboard:
            // Manually added the entry since it's already registered
            break
        case .nib:
            privateRegisterSupplementaryViewNib(type: type, identifier: identifier,
                                                kind: kind, bundle: bundle)
        case .class:
            privateRegisterSupplementaryViewClass(type: type, identifier: identifier,
                                                  kind: kind)
        case .default:

            // swiftlint:disable line_length
            if bundle.path(forResource: identifier, ofType: "nib") != nil {
                privateRegisterSupplementaryViewNib(type: type, identifier: identifier,
                                                    kind: kind, bundle: bundle)
                if logEnabled {
                    print("""
                        Registered \
                        'list.registerSupplementaryView(type: \(identifier).self, kind: \"\(kind)\", registerType: .nib)'
                        """)
                }
            } else {

                if let tableView = listView as? UITableView {
                    // Validate cell is not configured in storyboard
                    if tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) != nil {
                        if logEnabled {
                            print("""
                                Registered \
                                'list.registerSupplementaryView(type: \(identifier).self, kind: \"\(kind)\", registerType: .storyboard)'
                                """)
                        }
                    } else {
                        privateRegisterSupplementaryViewClass(type: type, identifier: identifier,
                                                              kind: kind)
                        if logEnabled {
                            print("""
                                Registered \
                                'list.registerSupplementaryView(type: \(identifier).self, kind: \"\(kind)\", registerType: .class)'
                                """)
                        }
                    }
                } else if (listView as? UICollectionView) != nil {

                    privateRegisterSupplementaryViewClass(type: type, identifier: identifier,
                                                          kind: kind)
                    if logEnabled {
                        print("""
                            Registered \
                            'list.registerSupplementaryView(type: \(identifier).self, kind: \"\(kind)\", registerType: .class)'. \
                            If it's registered with storyboard then manually register it using \
                            \n'list.registerSupplementaryView(type: \(identifier).self, kind: \"\(kind)\", registerType: .storyboard)'
                            """)
                    }
                }
            }
            // swiftlint:enable line_length
        }
    }
    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

    @MainActor
    private func privateRegisterSupplementaryViewNib<T: IQModelableSupplementaryView>(type: T.Type,
                                                                                      identifier: String,
                                                                                      kind: String,
                                                                                      bundle: Bundle) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        if let tableView = listView as? UITableView {
            if type is UITableViewHeaderFooterView.Type {
                tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
            }
        } else if let collectionView = listView as? UICollectionView {
            if type is UICollectionReusableView.Type {
                collectionView.register(nib, forSupplementaryViewOfKind: kind,
                                        withReuseIdentifier: identifier)
            }
        }
    }

    @MainActor
    private func privateRegisterSupplementaryViewClass<T: IQModelableSupplementaryView>(type: T.Type,
                                                                                        identifier: String,
                                                                                        kind: String) {
        if let tableView = listView as? UITableView {
            if type is UITableViewHeaderFooterView.Type {
                tableView.register(type.self, forHeaderFooterViewReuseIdentifier: identifier)
            }
        } else if let collectionView = listView as? UICollectionView {
            if type is UICollectionReusableView.Type {
                collectionView.register(type.self,
                                        forSupplementaryViewOfKind: kind,
                                        withReuseIdentifier: identifier)
            }
        }
    }
}

extension IQList {
    @available(*, unavailable, message: "This function parameters are shuffled",
                renamed: "registerCell(type:registerType:bundle:)")
    public func registerCell<T: IQModelableCell>(type: T.Type, bundle: Bundle? = .main,
                                                 registerType: RegisterType = .default) {
    }

    @available(*, unavailable, message: "This function has been renamed",
                renamed: "registerSupplementaryView(type:kind:registerType:bundle:)")
    func registerHeaderFooter<T: UIView>(type: T.Type, registerType: RegisterType, bundle: Bundle? = .main) {
    }
}
