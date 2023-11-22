//
//  IQDiffableDataSourceSnapshotBuilder+UpdateItem.swift
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

@ReloadActor
public extension IQDiffableDataSourceSnapshotBuilder {

    /// Append the models to the given section
    /// This method can also be used in background thread
    /// - Parameters:
    ///   - type: Type of the IQModelableCell
    ///   - models: the models of type IQModelableCell.Model
    ///   - section: section in which we'll be adding the models
    @discardableResult
    func append<T: IQModelableCell>(_ type: T.Type, models: [T.Model],
                                    section: IQSection? = nil,
                                    beforeItem: IQItem? = nil, afterItem: IQItem? = nil) -> [IQItem] {
        let items: [IQItem] = models.map { IQItem(type, model: $0) }

        if registeredCells.contains(where: { $0 == type}) == false,
            newCells.contains(where: { $0 == type}) == false {
            newCells.append(type)
        }

        return append(items, section: section, beforeItem: beforeItem, afterItem: afterItem)
    }

    @discardableResult
    func append<T: IQModelableCell, S: IQModelableSupplementaryView>(_ type: T.Type, models: [T.Model],
                                                                     supplementaryType: S.Type,
                                                                     supplementaryModels: [S.Model],
                                                                     section: IQSection? = nil,
                                                                     beforeItem: IQItem? = nil,
                                                                     afterItem: IQItem? = nil) -> [IQItem] {

        if registeredCells.contains(where: { $0 == type}) == false,
            newCells.contains(where: { $0 == type}) == false {
            newCells.append(type)
        }

        var items: [IQItem] = []
        for (index, model) in models.enumerated() {
            let item = IQItem(type, model: model, supplementaryType: supplementaryType,
                              supplementaryModel: supplementaryModels[index])
            items.append(item)
        }

        return append(items, section: section, beforeItem: beforeItem, afterItem: afterItem)
    }

    @discardableResult
    func append(_ items: [IQItem],
                section: IQSection? = nil,
                beforeItem: IQItem? = nil, afterItem: IQItem? = nil) -> [IQItem] {
        var items: [IQItem] = items
        if removeDuplicates {
            let existingItems = batchSnapshot.itemIdentifiers
            let result = items.removeDuplicate(existingElements: existingItems)
            items = result.unique
            if !result.duplicate.isEmpty {
                let duplicate = result.duplicate.compactMap { $0.model }
                print("IQListKit: Ignoring \(duplicate.count) duplicate elements.")
            }
        }

        if let section = section {
            batchSnapshot.appendItems(items, toSection: section)
        } else {
            if let beforeItem = beforeItem {
                batchSnapshot.insertItems(items, beforeItem: beforeItem)
            } else if let afterItem  = afterItem {
                batchSnapshot.insertItems(items, afterItem: afterItem)
            } else {
                batchSnapshot.appendItems(items)
            }
        }
        return items
    }

    // We are deleting and adding new items because the batchSnapshot not able
    // to find existing element if they aren't equal. So to update an element we
    // remove the existing one and add the new one at same location.
    @discardableResult
    func reload<T: IQModelableCell>(_ type: T.Type, models: [T.Model],
                                    comparator: (T.Model, T.Model) -> Bool) -> [IQItem] {

        let existingItems: [IQItem] = batchSnapshot.itemIdentifiers

        var reloadedItems: [IQItem] = []
        for model in models {
            if let index = existingItems.firstIndex(where: {
                if let existingModel = $0.model as? T.Model {
                    return comparator(existingModel, model)
                }
                return false
            }) {
                batchSnapshot.deleteItems([existingItems[index]])

                var item = existingItems[index]
                item.update(type, model: model)

                if index == 0 {
                    if existingItems.count > 1 {
                        batchSnapshot.insertItems([item], beforeItem: existingItems[index+1])
                    } else {
                        batchSnapshot.appendItems([item])
                    }
                } else {
                    batchSnapshot.insertItems([item], afterItem: existingItems[index-1])
                }
                reloadedItems.append(item)
            }
        }
        return reloadedItems
    }

    @available(iOS 15.0, *)
    @discardableResult
    func reconfigure<T: IQModelableCell>(_ type: T.Type, models: [T.Model],
                                         comparator: (T.Model, T.Model) -> Bool) -> [IQItem] {

        let existingItems: [IQItem] = batchSnapshot.itemIdentifiers

        var reconfiguredItems: [IQItem] = []
        for model in models {
            if let index = existingItems.firstIndex(where: {
                if let existingModel = $0.model as? T.Model {
                    return comparator(existingModel, model)
                }
                return false
            }) {
                var item = existingItems[index]
                item.update(type, model: model)
                reconfiguredItems.append(item)
            }
        }

        batchSnapshot.reconfigureItems(reconfiguredItems)
        return reconfiguredItems
    }

    @discardableResult
    func delete<T: IQModelableCell>(_ type: T.Type, models: [T.Model],
                                    comparator: (T.Model, T.Model) -> Bool) -> [IQItem] {

        let existingItems: [IQItem] = batchSnapshot.itemIdentifiers

        var deletedItems: [IQItem] = []
        for model in models {

            if let item = existingItems.first(where: {
                if let existingModel = $0.model as? T.Model {
                    return comparator(existingModel, model)
                }
                return false
            }) {
                deletedItems.append(item)
            }
        }

        if !deletedItems.isEmpty {
            batchSnapshot.deleteItems(deletedItems)
        }
        return deletedItems
    }

    func deleteAllItems() {
        batchSnapshot.deleteAllItems()
    }
}

extension IQDiffableDataSourceSnapshotBuilder {

    @available(*, unavailable, message: "This function is renamed to accept multiple models at once",
                renamed: "append(_:models:section:)")
    public func append<T: IQModelableCell>(_ type: T.Type, model: T.Model?, section: IQSection? = nil) {
    }
}
