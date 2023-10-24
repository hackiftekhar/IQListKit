//
//  IQTableViewDiffableDataSource.swift
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

// MARK: - Improved DiffableDataSource of UITableView

@MainActor
internal final class IQTableViewDiffableDataSource: UITableViewDiffableDataSource<IQSection, IQItem> {

    @MainActor internal var registeredCells: [IQListCell.Type] = []
    @MainActor internal var registeredSupplementaryViews: [String: [UIView.Type]] = [:]

    @MainActor weak var proxyDelegate: IQListViewProxyDelegate?
    @MainActor weak var delegate: IQListViewDelegate?
    @MainActor weak var dataSource: IQListViewDataSource?
    @MainActor internal var clearsSelectionOnDidSelect = true
    @MainActor internal var contextMenuPreviewIndexPath: IndexPath?

    override init(tableView: UITableView, cellProvider: @escaping IQTableViewDiffableDataSource.CellProvider) {
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return nil
        }
        let aSection: IQSection = sectionIdentifiers[section]

        guard aSection.headerType is IQSupplementaryViewPlaceholder.Type else {
            return nil
        }
        return aSection.headerModel as? String
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {

        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return nil
        }
        let aSection: IQSection = sectionIdentifiers[section]

        guard aSection.footerType is IQSupplementaryViewPlaceholder.Type else {
            return nil
        }
        return aSection.footerModel as? String
    }

    // MARK: - Editing

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return false
        }

        if let model: any IQReorderableModel = item.model as? any IQReorderableModel {
            return model.canEdit
        } else if let canEdit: Bool = dataSource?.listView(tableView, canEdit: item, at: indexPath) {
            return canEdit
        } else {
            return false
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {

        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        dataSource?.listView(tableView, commit: item, style: editingStyle, at: indexPath)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {

        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return false
        }

        if let model: any IQReorderableModel = item.model as? any IQReorderableModel {
            return model.canMove
        } else if let canMove: Bool = dataSource?.listView(tableView, canMove: item, at: indexPath) {
            return canMove
        } else {
            return false
        }
    }

    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        guard sourceIndexPath != destinationIndexPath else { return }

        guard let sourceItem: IQItem = itemIdentifier(for: sourceIndexPath) else {
            return
        }

        dataSource?.listView(tableView, move: sourceItem, at: sourceIndexPath, to: destinationIndexPath)
    }

    // MARK: - sectionIndexTitles

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        dataSource?.sectionIndexTitles(tableView)
    }

//    override func tableView(_ tableView: UITableView,
//      sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//
//    }
}
