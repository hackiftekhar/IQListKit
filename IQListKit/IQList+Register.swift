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
import SwiftTryCatch

// MARK: - Manual cell and header/footer registration

public extension IQList {

    enum RegisterType {
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
    // swiftlint:disable function_body_length
    func registerCell<T: IQModelableCell>(type: T.Type, registerType: RegisterType, bundle: Bundle = .main) {

        guard registeredCells.contains(where: { $0 == type}) == false else {
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
                registeredCells.append(type)    // Just manually adding the entry
            case .nib:
                registeredCells.append(type)
                internalRegisterNib()
            case .class:
                registeredCells.append(type)
                internalRegisterClass()
            case .default:

                var hasRegistered = false
                if let tableView = listView as? UITableView {
                    // Validate if the cell is configured in storyboard
                    if tableView.dequeueReusableCell(withIdentifier: identifier) != nil {
                        registeredCells.append(type)
                        hasRegistered = true
                        return
                    }
                } else if let collectionView = listView as? UICollectionView {
                    // Validate if the cell is configured in storyboard
                    SwiftTryCatch.try {
                        let dummyIndexPath = IndexPath(item: 0, section: 0)
                        _ = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: dummyIndexPath)
                        self.registeredCells.append(type)
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
                                      `list.registerCell(type: \(identifier).self, registerType: .\(typeName))`
                                      """)
                            }
                        }
                    } finally: {
                    }
                }

                guard !hasRegistered else {
                    return
                }

                registeredCells.append(type)
                if bundle.path(forResource: identifier, ofType: "nib") != nil {
                    internalRegisterNib()
                } else {
                    internalRegisterClass()
                }
            }
        }

        if Thread.isMainThread {
            internalRegisterCell()
        } else {
            DispatchQueue.main.sync {
                internalRegisterCell()
            }
        }
    }

    /// register a HeaderFooter manually
    /// - Parameters:
    ///   - type: Type of the header
    ///   - bundle: The bundle in which the header is present.
    func registerHeaderFooter<T: UIView>(type: T.Type, registerType: RegisterType, bundle: Bundle = .main) {

        guard registeredHeaderFooterViews.contains(where: { $0 == type}) == false else {
            return
        }

        let identifier = String(describing: type)

        func internalRegisterNib() {
            let nib = UINib(nibName: identifier, bundle: bundle)
            if let tableView = listView as? UITableView {
                registeredHeaderFooterViews.append(type)
                tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)

            } else if let collectionView = listView as? UICollectionView {
                registeredHeaderFooterViews.append(type)
                collectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                        withReuseIdentifier: identifier)
                collectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                        withReuseIdentifier: identifier)
            }
        }

        func internalRegisterClass() {
            if let tableView = listView as? UITableView {
                registeredHeaderFooterViews.append(type)
                tableView.register(type.self, forHeaderFooterViewReuseIdentifier: identifier)
            } else if let collectionView = listView as? UICollectionView {
                registeredHeaderFooterViews.append(type)
                collectionView.register(type.self,
                                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                        withReuseIdentifier: identifier)
                collectionView.register(type.self,
                                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                        withReuseIdentifier: identifier)
            }
        }

        func internalRegisterHeaderFooter() {

            switch registerType {
            case .storyboard:
                registeredHeaderFooterViews.append(type)    // Just manually adding the entry
            case .nib:
                registeredHeaderFooterViews.append(type)
                internalRegisterNib()
            case .class:
                registeredHeaderFooterViews.append(type)
                internalRegisterClass()
            case .default:

                var hasRegistered = false
                if let tableView = listView as? UITableView {
                    // Validate if the cell is configured in storyboard
                    if tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) != nil {
                        registeredHeaderFooterViews.append(type)
                        hasRegistered = true
                        return
                    }
                } else if let collectionView = listView as? UICollectionView {
                    // Validate if the cell is configured in storyboard
                    SwiftTryCatch.try {
                        let dummyIndexPath = IndexPath(item: 0, section: 0)
                        _ = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                            withReuseIdentifier: identifier,
                                                                            for: dummyIndexPath)
                        _ = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                            withReuseIdentifier: identifier,
                                                                            for: dummyIndexPath)
                        self.registeredHeaderFooterViews.append(type)
                        hasRegistered = true
                    } catch: { exception in
                        if let exception = exception {
                            if exception.name == NSExceptionName.internalInconsistencyException {

                                let typeName: String = {
                                    bundle.path(forResource: identifier, ofType: "nib") != nil ? "nib" : "class"
                                }()

                                print("""
                                      IQListKit: To remove assertion failure log, please manually register cell using \
                                      `list.registerHeaderFooter(type: \(identifier).self, registerType: .\(typeName))`
                                      """)
                            }
                        }
                    } finally: {
                    }
                }

                guard !hasRegistered else {
                    return
                }

                registeredHeaderFooterViews.append(type)
                if bundle.path(forResource: identifier, ofType: "nib") != nil {
                    internalRegisterNib()
                } else {
                    internalRegisterClass()
                }
            }
        }

        if Thread.isMainThread {
            internalRegisterHeaderFooter()
        } else {
            DispatchQueue.main.sync {
                internalRegisterHeaderFooter()
            }
        }
    }
}
