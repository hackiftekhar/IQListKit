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

    /// register a Cell manually
    /// - Parameters:
    ///   - type: Type of the cell
    ///   - bundle: The bundle in which the cell is present.
    ///   - registerType: The cell registration type
    @MainActor
    func registerCell<T: IQModelableCell>(type: T.Type,
                                          registerType: RegisterType,
                                          bundle: Bundle = .main) {

        guard diffableDataSource.registeredCells.contains(where: { $0 == type}) == false else {
            return
        }

        let identifier = String(describing: type)

        diffableDataSource.registeredCells.append(type)

        internalRegisterCell(type: type,
                             identifier: identifier,
                             registerType: registerType,
                             bundle: bundle)
    }

    @MainActor
    private func internalRegisterCell<T: IQModelableCell>(type: T.Type,
                                                          identifier: String,
                                                          registerType: RegisterType,
                                                          bundle: Bundle) {
        switch registerType {
        case .storyboard:
            // Manually added the entry since it's already registered
            break
        case .nib:
            internalRegisterCellNib(identifier: identifier, bundle: bundle)
        case .class:
            internalRegisterCellClass(type: type, identifier: identifier)
        case .default:

            if bundle.path(forResource: identifier, ofType: "nib") != nil {
                internalRegisterCellNib(identifier: identifier, bundle: bundle)
                print("""
                    Automatically registered nib of '\(type)' \
                    with identifier '\(identifier)'
                    """)
            } else {
                if let tableView = listView as? UITableView {
                    // Validate if the cell is configured in storyboard
                    if tableView.dequeueReusableCell(withIdentifier: identifier) != nil {
                        print("""
                            Automatically registered '\(type)' \
                            with identifier '\(identifier)' from storyboard'. \
                            Make sure storyboard cell identifier is '\(identifier)'
                            """)
                    } else {
                        internalRegisterCellClass(type: type, identifier: identifier)
                        print("""
                            Automatically registered class of '\(type)' \
                            with identifier '\(identifier)'
                            """)
                    }
                } else if (listView as? UICollectionView) != nil {
                    internalRegisterCellClass(type: type, identifier: identifier)
                    print("""
                        Automatically registered class of '\(type)' \
                        with identifier '\(identifier)' \
                        If it's registered with storyboard then \
                        manually register it using \
                        'list.registerCell(type: \(identifier).self, registerType: .storyboard)'. \
                        Also make sure storyboard cell identifier is '\(identifier)'.
                        """)
                }
            }
        }
    }

    @MainActor
    private func internalRegisterCellNib(identifier: String,
                                         bundle: Bundle) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        if let tableView = listView as? UITableView {
            tableView.register(nib, forCellReuseIdentifier: identifier)
        } else if let collectionView = listView as? UICollectionView {
            collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        }
    }

    @MainActor
    private func internalRegisterCellClass<T: IQModelableCell>(type: T.Type,
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
    func registerSupplementaryView<T: UIView>(type: T.Type, kind: String,
                                              registerType: RegisterType,
                                              bundle: Bundle = .main) {

        let identifier = String(describing: type)

        let existingTypes: [UIView.Type] = diffableDataSource.registeredSupplementaryViews[kind] ?? []
        guard existingTypes.contains(where: {$0 == type}) == false else {
            return
        }

        var newTypes: [UIView.Type] = existingTypes
        newTypes.append(type)
        diffableDataSource.registeredSupplementaryViews[kind] = newTypes

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            internalRegisterSupplementaryView(type: type, identifier: identifier,
                                              kind: kind, registerType: registerType)
        }
    }

    @MainActor
    private func internalRegisterSupplementaryView<T: UIView>(type: T.Type,
                                                              identifier: String,
                                                              kind: String,
                                                              registerType: RegisterType,
                                                              bundle: Bundle = .main) {

        switch registerType {
        case .storyboard:
            // Manually added the entry since it's already registered
            break
        case .nib:
            internalRegisterSupplementaryViewNib(type: type, identifier: identifier,
                                                 kind: kind, bundle: bundle)
        case .class:
            internalRegisterSupplementaryViewClass(type: type, identifier: identifier,
                                                   kind: kind)
        case .default:

            if bundle.path(forResource: identifier, ofType: "nib") != nil {
                internalRegisterSupplementaryViewNib(type: type, identifier: identifier,
                                                     kind: kind, bundle: bundle)
                print("""
                    Automatically registered nib of '\(type)' \
                    with identifier '\(identifier)' of kind '\(kind)'
                    """)
            } else {

                if let tableView = listView as? UITableView {
                    // Validate cell is not configured in storyboard
                    if tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) != nil {
                        print("""
                            Automatically registered '\(type)' \
                            with identifier '\(identifier)' of kind '\(kind)' from storyboard'. \
                            Make sure storyboard identifier is '\(identifier)'
                            """)
                    } else {
                        internalRegisterSupplementaryViewClass(type: type, identifier: identifier,
                                                               kind: kind)
                        print("""
                            Automatically registered class of '\(type)' \
                            with identifier '\(identifier)' of kind '\(kind)'
                            """)
                    }
                } else if (listView as? UICollectionView) != nil {

                    internalRegisterSupplementaryViewClass(type: type, identifier: identifier,
                                                           kind: kind)
                    print("""
                        Automatically registered class of '\(type)' \
                        with identifier '\(identifier)' of kind '\(kind)'. \
                        If it's registered with storyboard then \
                        manually register it using \
                        'list.registerSupplementaryView(type: \(identifier).self,
                                       kind: \"\(kind)\", registerType: .storyboard)'
                        """)
                }
            }
        }
    }

    @MainActor
    private func internalRegisterSupplementaryViewNib<T: UIView>(type: T.Type,
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
    private func internalRegisterSupplementaryViewClass<T: UIView>(type: T.Type,
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
