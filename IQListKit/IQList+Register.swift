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

    enum RegisterType {
        case `default`
        case nib
        case `class`
        case storyboard
    }

    // swiftlint:disable function_body_length
    /// register a Cell manually
    /// - Parameters:
    ///   - type: Type of the cell
    ///   - bundle: The bundle in which the cell is present.
    ///   - registerType: The cell registration type
    func registerCell<T: IQModelableCell>(type: T.Type,
                                          registerType: RegisterType, bundle: Bundle = .main) {

        guard diffableDataSource.registeredCells.contains(where: { $0 == type}) == false else {
            return
        }

        let identifier = String(describing: type)

        func internalRegisterNib() {
            let nib = UINib(nibName: identifier, bundle: bundle)
            if let tableView = listView as? UITableView {
                tableView.register(nib, forCellReuseIdentifier: identifier)
            } else if let collectionView = listView as? UICollectionView {
                collectionView.register(nib, forCellWithReuseIdentifier: identifier)
            }
        }

        func internalRegisterClass() {
            if let tableView = listView as? UITableView {
                tableView.register(type.self, forCellReuseIdentifier: identifier)
            } else if let collectionView = listView as? UICollectionView {
                collectionView.register(type.self, forCellWithReuseIdentifier: identifier)
            }
        }

        // swiftlint:disable cyclomatic_complexity
        func internalRegisterCell() {
            switch registerType {
            case .storyboard:
                diffableDataSource.registeredCells.append(type)    // Just manually adding the entry
            case .nib:
                diffableDataSource.registeredCells.append(type)
                internalRegisterNib()
            case .class:
                diffableDataSource.registeredCells.append(type)
                internalRegisterClass()
            case .default:

                var hasRegistered = false
                if let tableView = listView as? UITableView {
                    // Validate if the cell is configured in storyboard
                    if tableView.dequeueReusableCell(withIdentifier: identifier) != nil {
                        diffableDataSource.registeredCells.append(type)
                        hasRegistered = true
                        return
                    }
                } else if let collectionView = listView as? UICollectionView {
                    // Validate if the cell is configured in storyboard

#if canImport(SwiftTryCatch)
                    SwiftTryCatch.try { [weak self] in
                        let dummyIndexPath = IndexPath(item: 0, section: 0)
                        _ = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: dummyIndexPath)
                        self?.diffableDataSource.registeredCells.append(type)
                        hasRegistered = true
                    } catch: { exception in
                        if let exception = exception {
                            if exception.name == NSExceptionName.internalInconsistencyException {

                                let typeName: String = {
                                    bundle.path(forResource: identifier, ofType: "nib") != nil ? "nib" : "class"
                                }()

                                print("""
                                      IQListKit: To remove assertion failure log, please manually register cell using \
                                      `list.registerCell(type: \(identifier).self, registerType: .\(typeName))`
                                      """)
                            }
                        }
                    } finally: {
                    }
#else
                    let dummyIndexPath = IndexPath(item: 0, section: 0)
                    _ = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: dummyIndexPath)
                    diffableDataSource.registeredCells.append(type)
                    hasRegistered = true
#endif
                }

                guard !hasRegistered else {
                    return
                }

                diffableDataSource.registeredCells.append(type)
                if bundle.path(forResource: identifier, ofType: "nib") != nil {
                    internalRegisterNib()
                } else {
                    internalRegisterClass()
                }
            }
        }
        // swiftlint:enable cyclomatic_complexity

        if Thread.isMainThread {
            internalRegisterCell()
        } else {
            DispatchQueue.main.sync {
                internalRegisterCell()
            }
        }
    }
    // swiftlint:enable function_body_length

    // swiftlint:disable function_body_length
    /// register a supplementary view manually
    /// - Parameters:
    ///   - type: Type of the header
    ///   - bundle: The bundle in which the header is present.
    func registerSupplementaryView<T: UIView>(type: T.Type, kind: String,
                                              registerType: RegisterType,
                                              bundle: Bundle = .main) {

        let identifier = String(describing: type)

        var existingTypes: [UIView.Type] = diffableDataSource.registeredSupplementaryViews[kind] ?? []
        guard existingTypes.contains(where: {$0 == type}) == false else {
            return
        }

        func internalRegisterNib() {
            let nib = UINib(nibName: identifier, bundle: bundle)
            if let tableView = listView as? UITableView {
                existingTypes.append(type)
                diffableDataSource.registeredSupplementaryViews[kind] = existingTypes
                tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)

            } else if let collectionView = listView as? UICollectionView {
                existingTypes.append(type)
                diffableDataSource.registeredSupplementaryViews[kind] = existingTypes
                collectionView.register(nib, forSupplementaryViewOfKind: kind,
                                        withReuseIdentifier: identifier)
            }
        }

        func internalRegisterClass() {
            if let tableView = listView as? UITableView {
                existingTypes.append(type)
                diffableDataSource.registeredSupplementaryViews[kind] = existingTypes
                tableView.register(type.self, forHeaderFooterViewReuseIdentifier: identifier)
            } else if let collectionView = listView as? UICollectionView {
                existingTypes.append(type)
                diffableDataSource.registeredSupplementaryViews[kind] = existingTypes
                collectionView.register(type.self,
                                        forSupplementaryViewOfKind: kind,
                                        withReuseIdentifier: identifier)
            }
        }

        // swiftlint:disable cyclomatic_complexity
        func internalRegisterSupplementaryView() {

            switch registerType {
            case .storyboard:
                existingTypes.append(type)  // Just manually adding the entry
                diffableDataSource.registeredSupplementaryViews[kind] = existingTypes
            case .nib:
                internalRegisterNib()
            case .class:
                internalRegisterClass()
            case .default:

                var hasRegistered = false
                if let tableView = listView as? UITableView {
                    // Validate if the cell is configured in storyboard
                    if tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) != nil {
                        hasRegistered = true
                    }
                } else if let collectionView = listView as? UICollectionView {
                    // Validate if the cell is configured in storyboard
#if canImport(SwiftTryCatch)
                    SwiftTryCatch.try {
                        let dummyIndexPath = IndexPath(item: 0, section: 0)
                        _ = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                            withReuseIdentifier: identifier,
                                                                            for: dummyIndexPath)
                        hasRegistered = true
                    } catch: { exception in
                        if let exception = exception {
                            if exception.name == NSExceptionName.internalInconsistencyException {

                                let typeName: String = {
                                    bundle.path(forResource: identifier, ofType: "nib") != nil ? "nib" : "class"
                                }()

                                // swiftlint:disable line_length
                                print("""
                                      IQListKit: To remove assertion failure log, please manually register cell using \
                                      `list.registerSupplementaryView(type: \(identifier).self, kind: \(kind), registerType: .\(typeName))`
                                      """)
                                // swiftlint:enable line_length
                            }
                        }
                    } finally: {
                    }
#else
                    let dummyIndexPath = IndexPath(item: 0, section: 0)
                    _ = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                        withReuseIdentifier: identifier,
                                                                        for: dummyIndexPath)
                    hasRegistered = true
#endif
                }

                guard !hasRegistered else {
                    existingTypes.append(type)
                    diffableDataSource.registeredSupplementaryViews[kind] = existingTypes
                    return
                }

                if bundle.path(forResource: identifier, ofType: "nib") != nil {
                    internalRegisterNib()
                } else {
                    internalRegisterClass()
                }
            }
        }
        // swiftlint:enable cyclomatic_complexity

        if Thread.isMainThread {
            internalRegisterSupplementaryView()
        } else {
            DispatchQueue.main.sync {
                internalRegisterSupplementaryView()
            }
        }
    }
    // swiftlint:enable function_body_length
}
