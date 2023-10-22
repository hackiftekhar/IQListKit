//
//  IQDiffableDataSourceSnapshotWrapper+UpdateItem.swift
//  IQListKit
//
//  Created by Iftekhar on 10/22/23.
//

import UIKit

extension IQDiffableDataSourceSnapshotWrapper {

    /// Append the models to the given section
    /// This method can also be used in background thread
    /// - Parameters:
    ///   - type: Type of the IQModelableCell
    ///   - models: the models of type IQModelableCell.Model
    ///   - section: section in which we'll be adding the models
    @discardableResult
    nonisolated
    func append<T: IQModelableCell>(_ type: T.Type, models: [T.Model],
                                    section: IQSection? = nil,
                                    beforeItem: IQItem? = nil, afterItem: IQItem? = nil) -> [IQItem] {
        var items: [IQItem] = []
        for model in models {
            let item = IQItem(type, model: model)
            items.append(item)
        }

        return append(items, section: section, beforeItem: beforeItem, afterItem: afterItem)
    }

    @discardableResult
    nonisolated
    func append<T: IQModelableCell, S: IQModelableSupplementaryView>(_ type: T.Type, models: [T.Model],
                                                                     supplementaryType: S.Type,
                                                                     supplementaryModels: [S.Model],
                                                                     section: IQSection? = nil,
                                                                     beforeItem: IQItem? = nil,
                                                                     afterItem: IQItem? = nil) -> [IQItem] {
        var items: [IQItem] = []
        for (index, model) in models.enumerated() {
            let item = IQItem(type, model: model, supplementaryType: supplementaryType,
                              supplementaryModel: supplementaryModels[index])
            items.append(item)
        }

        return append(items, section: section, beforeItem: beforeItem, afterItem: afterItem)
    }

    @discardableResult
    nonisolated
    func append(_ items: [IQItem],
                section: IQSection? = nil,
                beforeItem: IQItem? = nil, afterItem: IQItem? = nil) -> [IQItem] {
        var items: [IQItem] = items
        if removeDuplicatesWhenReloading {
            let existingItems = batchSnapshot.itemIdentifiers
            let result = items.removeDuplicate(existingElements: existingItems)
            items = result.unique
            if !result.duplicate.isEmpty {
                let duplicate = result.duplicate.compactMap { $0.model }
                print("IQListKit: Ignoring \(duplicate.count) duplicate elements.")// \n\(duplicate))")
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
    nonisolated
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
    nonisolated
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
    nonisolated
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

    nonisolated
    func deleteAllItems() {
        batchSnapshot.deleteAllItems()
    }
}
