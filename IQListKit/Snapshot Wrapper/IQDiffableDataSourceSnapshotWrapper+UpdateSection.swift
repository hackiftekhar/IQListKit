//
//  IQDiffableDataSourceSnapshotWrapper+UpdateSection.swift
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
extension IQDiffableDataSourceSnapshotWrapper {

    /// Appends a section to the list
    /// This method can also be used in background thread
    /// - Parameter sections: sections which needs to be added to the list
    func append(_ sections: [IQSection], beforeSection: IQSection? = nil, afterSection: IQSection? = nil) {

        let existingHeaderTypes = registeredSupplementaryViews[IQList.elementKindSectionHeader] ?? []
        let existingFooterTypes = registeredSupplementaryViews[IQList.elementKindSectionFooter] ?? []

        sections.forEach { section in
            if let headerType = section.headerType,
               !(headerType is IQSupplementaryViewPlaceholder.Type) {
                let newTypes = newSupplementaryViews[IQList.elementKindSectionHeader] ?? []
                if existingHeaderTypes.contains(where: {$0 == headerType}) == false,
                   newTypes.contains(where: {$0 == headerType}) == false {

                    var newTypes: [any IQModelableSupplementaryView.Type] = newTypes
                    newTypes.append(headerType)

                    newSupplementaryViews[IQList.elementKindSectionHeader] = newTypes
                }
            }

            if let footerType = section.footerType,
               !(footerType is IQSupplementaryViewPlaceholder.Type) {
                let newTypes = newSupplementaryViews[IQList.elementKindSectionFooter] ?? []
                if existingFooterTypes.contains(where: {$0 == footerType}) == false,
                   newTypes.contains(where: {$0 == footerType}) == false {

                    var newTypes: [any IQModelableSupplementaryView.Type] = newTypes
                    newTypes.append(footerType)

                    newSupplementaryViews[IQList.elementKindSectionFooter] = newTypes
                }
            }
        }

        if let beforeSection = beforeSection {
            batchSnapshot.insertSections(sections, beforeSection: beforeSection)
        } else if let afterSection = afterSection {
            batchSnapshot.insertSections(sections, afterSection: afterSection)
        } else {
            batchSnapshot.appendSections(sections)
        }
    }

    func reload(_ sections: [IQSection]) {
        batchSnapshot.reloadSections(sections)
    }

    func delete(_ sections: [IQSection]) {
        batchSnapshot.deleteSections(sections)
    }
}
