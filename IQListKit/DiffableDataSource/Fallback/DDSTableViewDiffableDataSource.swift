//
//  DDSTableViewDiffableDataSource.swift
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
import DiffableDataSources

// MARK: Improved DiffableDataSource of UITableView

@available(iOS, deprecated: 13.0)
internal final class DDSTableViewDiffableDataSource: TableViewDiffableDataSource<IQSection, IQItem> {

    private let _tableViewDiffableDataSource: IQCommonTableViewDiffableDataSource =
        IQCommonTableViewDiffableDataSource()

    weak var delegate: IQListViewDelegate? {
        get {   _tableViewDiffableDataSource.delegate   }
        set {   _tableViewDiffableDataSource.delegate = newValue    }
    }

    weak var dataSource: IQListViewDataSource? {
        get {   _tableViewDiffableDataSource.dataSource }
        set {   _tableViewDiffableDataSource.dataSource = newValue  }
    }

    var clearsSelectionOnDidSelect: Bool {
        get {   _tableViewDiffableDataSource.clearsSelectionOnDidSelect }
        set {   _tableViewDiffableDataSource.clearsSelectionOnDidSelect = newValue  }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let aSection = snapshot().sectionIdentifiers[section]
        return _tableViewDiffableDataSource.tableView(tableView, titleForHeaderInSection: aSection)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let aSection = snapshot().sectionIdentifiers[section]
        return _tableViewDiffableDataSource.tableView(tableView, titleForFooterInSection: aSection)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        _tableViewDiffableDataSource.tableView(tableView, canEditRowAt: indexPath)
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        _tableViewDiffableDataSource.sectionIndexTitles(for: tableView)
    }
}

@available(iOS, deprecated: 13.0)
extension DDSTableViewDiffableDataSource: UITableViewDelegate {

    // MARK: - Header Footer

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let aSection = snapshot().sectionIdentifiers[section]
        return _tableViewDiffableDataSource.tableView(tableView, estimatedHeightForHeaderInSection: aSection)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let aSection = snapshot().sectionIdentifiers[section]
        return _tableViewDiffableDataSource.tableView(tableView, estimatedHeightForFooterInSection: aSection)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let aSection = snapshot().sectionIdentifiers[section]
        return _tableViewDiffableDataSource.tableView(tableView, heightForHeaderInSection: aSection)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let aSection = snapshot().sectionIdentifiers[section]
        return _tableViewDiffableDataSource.tableView(tableView, heightForFooterInSection: aSection)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let aSection = snapshot().sectionIdentifiers[section]
        return _tableViewDiffableDataSource.tableView(tableView, viewForHeaderInSection: section, section: aSection)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let aSection = snapshot().sectionIdentifiers[section]
        return _tableViewDiffableDataSource.tableView(tableView, viewForFooterInSection: section, section: aSection)
    }

    // MARK: - Cell

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let item: IQItem? = itemIdentifier(for: indexPath)
        return _tableViewDiffableDataSource.tableView(tableView, estimatedHeightForRowAt: item)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item: IQItem? = itemIdentifier(for: indexPath)
        return _tableViewDiffableDataSource.tableView(tableView, heightForRowAt: indexPath, item: item)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        _tableViewDiffableDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        _tableViewDiffableDataSource.tableView(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }

    // MARK: - Selection

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        _tableViewDiffableDataSource.tableView(tableView, shouldHighlightRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        _tableViewDiffableDataSource.tableView(tableView, willSelectRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: IQItem? = itemIdentifier(for: indexPath)
        _tableViewDiffableDataSource.tableView(tableView, didSelectRowAt: indexPath, item: item)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let item: IQItem? = itemIdentifier(for: indexPath)
        _tableViewDiffableDataSource.tableView(tableView, didDeselectRowAt: indexPath, item: item)
    }

    // MARK: - Swipe actions
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        _tableViewDiffableDataSource.tableView(tableView, editingStyleForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        _tableViewDiffableDataSource.tableView(tableView, editActionsForRowAt: indexPath)
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        _tableViewDiffableDataSource.tableView(tableView, leadingSwipeActionsConfigurationForRowAt: indexPath)
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        _tableViewDiffableDataSource.tableView(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
    }

    // MARK: - Context menu

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        _tableViewDiffableDataSource.tableView(tableView,
                                               contextMenuConfigurationForRowAt: indexPath,
                                               point: point)
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView,
                   previewForHighlightingContextMenuWithConfiguration
                    configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        _tableViewDiffableDataSource.tableView(tableView,
                                               previewForHighlightingContextMenuWithConfiguration: configuration)
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView,
                   willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionCommitAnimating) {
        _tableViewDiffableDataSource.tableView(tableView,
                                               willPerformPreviewActionForMenuWith: configuration,
                                               animator: animator)
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView,
                   previewForDismissingContextMenuWithConfiguration
                    configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        _tableViewDiffableDataSource.tableView(tableView,
                                               previewForDismissingContextMenuWithConfiguration: configuration)
    }
}
