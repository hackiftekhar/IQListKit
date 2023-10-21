//
//  IQList+UpdateSection.swift
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

    /// Appends a section to the list
    /// This method can also be used in background thread
    /// - Parameter sections: sections which needs to be added to the list
    nonisolated func append(_ sections: [IQSection], beforeSection: IQSection? = nil, afterSection: IQSection? = nil) {
        if let beforeSection = beforeSection {
            batchSnapshot.insertSections(sections, beforeSection: beforeSection)
        } else if let afterSection = afterSection {
            batchSnapshot.insertSections(sections, afterSection: afterSection)
        } else {
            batchSnapshot.appendSections(sections)
        }
    }

    nonisolated func reload(_ sections: [IQSection]) {
        batchSnapshot.reloadSections(sections)
    }

    nonisolated func delete(_ sections: [IQSection]) {
        batchSnapshot.deleteSections(sections)
    }
}
