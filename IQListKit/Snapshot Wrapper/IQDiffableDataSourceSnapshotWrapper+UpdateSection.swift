//
//  IQDiffableDataSourceSnapshotWrapper+UpdateSection.swift
//  IQListKit
//
//  Created by Iftekhar on 10/22/23.
//

import UIKit

extension IQDiffableDataSourceSnapshotWrapper {

    /// Appends a section to the list
    /// This method can also be used in background thread
    /// - Parameter sections: sections which needs to be added to the list
    nonisolated
    func append(_ sections: [IQSection], beforeSection: IQSection? = nil, afterSection: IQSection? = nil) {
        if let beforeSection = beforeSection {
            batchSnapshot.insertSections(sections, beforeSection: beforeSection)
        } else if let afterSection = afterSection {
            batchSnapshot.insertSections(sections, afterSection: afterSection)
        } else {
            batchSnapshot.appendSections(sections)
        }
    }

    nonisolated
    func reload(_ sections: [IQSection]) {
        batchSnapshot.reloadSections(sections)
    }

    nonisolated
    func delete(_ sections: [IQSection]) {
        batchSnapshot.deleteSections(sections)
    }
}
