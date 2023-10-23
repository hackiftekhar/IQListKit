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
    @discardableResult
    nonisolated
    func append<T: IQModelableCell>(_ type: T.Type, models: [T.Model],
                                    section: IQSection? = nil,
                                    beforeItem: IQItem? = nil,
                                    afterItem: IQItem? = nil) -> [IQItem] {
        if cellRegisterType == .automatic {
            registerCell(type: type, registerType: .default)
        }

        return snapshotWrapper.append(type, models: models, section: section,
                                      beforeItem: beforeItem, afterItem: afterItem)
    }

    @discardableResult
    nonisolated
    func append<T: IQModelableCell, S: IQModelableSupplementaryView>(_ type: T.Type, models: [T.Model],
                                                                     supplementaryType: S.Type,
                                                                     supplementaryModels: [S.Model],
                                                                     section: IQSection? = nil,
                                                                     beforeItem: IQItem? = nil,
                                                                     afterItem: IQItem? = nil) -> [IQItem] {
        if cellRegisterType == .automatic {
            registerCell(type: type, registerType: .default)
        }

        return snapshotWrapper.append(type, models: models,
                                      supplementaryType: supplementaryType, supplementaryModels: supplementaryModels,
                                      section: section, beforeItem: beforeItem, afterItem: afterItem)
    }

    @discardableResult
    nonisolated
    func append(_ items: [IQItem],
                section: IQSection? = nil,
                beforeItem: IQItem? = nil,
                afterItem: IQItem? = nil) -> [IQItem] {
        return snapshotWrapper.append(items, section: section, beforeItem: beforeItem, afterItem: afterItem)
    }

    // We are deleting and adding new items because the batchSnapshot not able
    // to find existing element if they aren't equal. So to update an element we
    // remove the existing one and add the new one at same location.
    @discardableResult
    nonisolated
    func reload<T: IQModelableCell>(_ type: T.Type, models: [T.Model],
                                    comparator: (T.Model, T.Model) -> Bool) -> [IQItem] {
        return snapshotWrapper.reload(type, models: models, comparator: comparator)
    }

    @available(iOS 15.0, *)
    @discardableResult
    nonisolated
    func reconfigure<T: IQModelableCell>(_ type: T.Type, models: [T.Model],
                                         comparator: (T.Model, T.Model) -> Bool) -> [IQItem] {
        return snapshotWrapper.reconfigure(type, models: models, comparator: comparator)
    }

    @discardableResult
    nonisolated
    func delete<T: IQModelableCell>(_ type: T.Type, models: [T.Model],
                                    comparator: (T.Model, T.Model) -> Bool) -> [IQItem] {
        return snapshotWrapper.delete(type, models: models, comparator: comparator)
    }

    nonisolated
    func deleteAllItems() {
        return snapshotWrapper.deleteAllItems()
    }
}
