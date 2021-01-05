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

// MARK: - Manual cell and header/footer registration

public extension IQList {

    enum RegisterType {
        case `default`
        case nib
        case `class`
        case storyboard
    }

    func registerCell<T: IQModelableCell>(type: T.Type, bundle: Bundle? = .main,
                                          registerType: RegisterType = .default) {

        guard registeredCells.contains(where: { $0 == type}) == false else {
            return
        }

        func internalRegisterCell() {
            let identifier = String(describing: type)

            if registerType == .default, let tableView = listView as? UITableView {
                // Validate if the cell is configured in storyboard
                if tableView.dequeueReusableCell(withIdentifier: identifier) != nil {
                    registeredCells.append(type)
                    return
                }
            }

            if registerType == .storyboard {
                registeredCells.append(type)
            } else if (registerType == .default || registerType == .nib),
               bundle?.path(forResource: identifier, ofType: "nib") != nil {
                let nib = UINib(nibName: identifier, bundle: bundle)
                if let tableView = listView as? UITableView {
                    registeredCells.append(type)
                    tableView.register(nib, forCellReuseIdentifier: identifier)
                } else if let collectionView = listView as? UICollectionView {
                    registeredCells.append(type)
                    collectionView.register(nib, forCellWithReuseIdentifier: identifier)
                }
            } else if registerType == .default || registerType == .class {
                if let tableView = listView as? UITableView {
                    registeredCells.append(type)
                    tableView.register(type.self, forCellReuseIdentifier: identifier)
                } else if let collectionView = listView as? UICollectionView {
                    registeredCells.append(type)
                    collectionView.register(type.self, forCellWithReuseIdentifier: identifier)
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

    func registerHeaderFooter<T: UIView>(type: T.Type, bundle: Bundle? = .main) {

        guard registeredHeaderFooterViews.contains(where: { $0 == type}) == false else {
            return
        }

        func internalRegisterHeaderFooter() {
            let identifier = String(describing: type)

            if bundle?.path(forResource: identifier, ofType: "nib") != nil {
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
            } else {
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
