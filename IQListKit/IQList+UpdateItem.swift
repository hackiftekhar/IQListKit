//
//  IQList+UpdateItem.swift
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

// MARK: - Update the list
/// Note that all these methods can also be used in a background threads since they all
/// methods deal with the models, not any UI elements.
/// NSDiffableDataSourceSnapshot.apply is also background thread safe
public extension IQList {

    /// Append the models to the given section
    /// This method can also be used in background thread
    /// - Parameters:
    ///   - type: Type of the IQModelableCell
    ///   - models: the models of type IQModelableCell.Model
    ///   - section: section in which we'll be adding the models
    func append<T: IQModelableCell>(_ type: T.Type, models: [T.Model],
                                    section: IQSection? = nil,
                                    beforeItem: IQItem? = nil, afterItem: IQItem? = nil) {

        if registeredCells.contains(where: { $0 == type}) == false {
            registerCell(type: type, registerType: .default)
        }

        var items: [IQItem] = []
        for model in models {
            let item = IQItem(type, model: model)
            items.append(item)
        }

        if removeDuplicatesWhenReloading {
            let existingItems = batchSnapshot.itemIdentifiers
            let result = items.removeDuplicate(existingElements: existingItems)
            items = result.unique
            if !result.duplicate.isEmpty {
                let duplicate = result.duplicate.compactMap { $0.model }
                print("IQListKit: Ignoring \(duplicate.count) duplicate elements.\n\(duplicate))")
            }
        }

        if let section = section {
            batchSnapshot.appendItems(items, toSection: section)
        } else {
            if let beforeItem  = beforeItem {
                batchSnapshot.insertItems(items, beforeItem: beforeItem)
            } else if let afterItem  = afterItem {
                batchSnapshot.insertItems(items, afterItem: afterItem)
            } else {
                batchSnapshot.appendItems(items)
            }
        }
    }

    func reload<T: IQModelableCell>(_ type: T.Type, models: [T.Model]) {

        let existingItems: [IQItem] = batchSnapshot.itemIdentifiers

        var updatedItems: [IQItem] = []
        for model in models {

            if let item = existingItems.first(where: {
                if let existingModel = $0.model as? T.Model {
                    return existingModel == model
                }
                return false
            }) {
                item.update(type, model: model)
                updatedItems.append(item)
            }
        }

        batchSnapshot.reloadItems(updatedItems)
    }

    func delete<T: IQModelableCell>(_ type: T.Type, models: [T.Model]) {

        let existingItems: [IQItem] = batchSnapshot.itemIdentifiers

        var deletedItems: [IQItem] = []
        for model in models {

            if let item = existingItems.first(where: {
                if let existingModel = $0.model as? T.Model {
                    return existingModel == model
                }
                return false
            }) {
                deletedItems.append(item)
            }
        }

        batchSnapshot.deleteItems(deletedItems)
    }

    func deleteAllItems() {
        batchSnapshot.deleteAllItems()
    }
}
