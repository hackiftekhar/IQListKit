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

internal final class IQTableViewDiffableDataSource: UITableViewDiffableDataSource<IQSection, IQItem> {

    weak var delegate: IQListViewDelegate?
    weak var dataSource: IQListViewDataSource?
    var clearsSelectionOnDidSelect = true
    private var contextMenuPreviewIndexPath: IndexPath?

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section: IQSection = snapshot().sectionIdentifiers[section]
        return section.header
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section: IQSection = snapshot().sectionIdentifiers[section]
        return section.footer
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        dataSource?.sectionIndexTitles(tableView)
    }
}

extension IQTableViewDiffableDataSource: UITableViewDelegate {

    // MARK: - Header Footer

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let section: IQSection = snapshot().sectionIdentifiers[section]

        if let headerSize: CGSize = section.headerSize {
            return headerSize.height
        } else if let headerView: UIView = section.headerView {
            return headerView.frame.height
        } else if section.header != nil {
            return tableView.sectionHeaderHeight
        } else {
            return tableView.estimatedSectionHeaderHeight
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let section: IQSection = snapshot().sectionIdentifiers[section]

        if let footerSize: CGSize = section.footerSize {
            return footerSize.height
        } else if let footerView: UIView = section.footerView {
            return footerView.frame.height
        } else if section.footer != nil {
            return tableView.sectionFooterHeight
        } else {
            return tableView.estimatedSectionFooterHeight
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section: IQSection = snapshot().sectionIdentifiers[section]

        if let headerSize: CGSize = section.headerSize {
            return headerSize.height
        } else if let headerView: UIView = section.headerView {
            return headerView.frame.height
        } else if section.header != nil {
            return tableView.sectionHeaderHeight
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section: IQSection = snapshot().sectionIdentifiers[section]

        if let footerSize: CGSize = section.footerSize {
            return footerSize.height
        } else if let footerView: UIView = section.footerView {
            return footerView.frame.height
        } else if section.footer != nil {
            return tableView.sectionFooterHeight
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let aSection: IQSection = snapshot().sectionIdentifiers[section]

        let view: UIView? = dataSource?.listView(tableView, headerFor: aSection, at: section)
        if let headerView: UIView = view ?? aSection.headerView {
            delegate?.listView(tableView, modifyHeader: headerView, section: aSection, at: section)
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let aSection: IQSection = snapshot().sectionIdentifiers[section]

        let view: UIView? = dataSource?.listView(tableView, footerFor: aSection, at: section)
        if let footerView: UIView = view ?? aSection.footerView {
            delegate?.listView(tableView, modifyFooter: footerView, section: aSection, at: section)
            return footerView
        }
        return nil
    }

    // MARK: - Cell

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item: IQItem = itemIdentifier(for: indexPath),
                let type: IQCellSizeProvider.Type = item.type as? IQCellSizeProvider.Type else {
            return UITableView.automaticDimension
        }

        return type.estimatedSize(for: item.model, listView: tableView).height
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return UITableView.automaticDimension
        }

        if let size: CGSize = dataSource?.listView(tableView, size: item, at: indexPath) {
            return size.height
        } else if let type: IQCellSizeProvider.Type = item.type as? IQCellSizeProvider.Type {
            return type.size(for: item.model, listView: tableView).height
        }

        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.listView(tableView, willDisplay: cell, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.listView(tableView, didEndDisplaying: cell, at: indexPath)
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {

        guard let item: IQItem = itemIdentifier(for: indexPath),
              let type: IQCellSizeProvider.Type = item.type as? IQCellSizeProvider.Type else {
            return 0
        }

        return type.indentationLevel(for: item.model, listView: tableView)
    }

    // MARK: - Selection

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {

        guard let cell: IQSelectableCell = tableView.cellForRow(at: indexPath) as? IQSelectableCell else {
            return true
        }

        return cell.isHighlightable
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let cell: IQSelectableCell = tableView.cellForRow(at: indexPath) as? IQSelectableCell else {
            return indexPath
        }

        return cell.isSelectable ? indexPath : nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if clearsSelectionOnDidSelect {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(tableView, didSelect: item, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(tableView, didDeselect: item, at: indexPath)
    }

    // MARK: - Swipe actions
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard let cell: IQCellActionsProvider = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let swipeActions: [IQContextualAction] = cell.leadingSwipeActions() else {
            return nil
        }

        var contextualSwipeActions: [UIContextualAction] = [UIContextualAction]()

        for action in swipeActions {
            contextualSwipeActions.append(action.contextualAction())
        }

        return UISwipeActionsConfiguration(actions: contextualSwipeActions)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard let cell: IQCellActionsProvider = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let swipeActions: [IQContextualAction] = cell.trailingSwipeActions() else {
            return nil
        }

        var contextualSwipeActions: [UIContextualAction] = [UIContextualAction]()

        for action in swipeActions {
            contextualSwipeActions.append(action.contextualAction())
        }

        return UISwipeActionsConfiguration(actions: contextualSwipeActions)
    }

    // MARK: - Context menu

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {

        guard let cell: IQCellActionsProvider = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let configuration: UIContextMenuConfiguration = cell.contextMenuConfiguration() else {
            return nil
        }

        contextMenuPreviewIndexPath = indexPath
        return configuration
    }

    func tableView(_ tableView: UITableView,
                   previewForHighlightingContextMenuWithConfiguration
                    configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard let indexPath: IndexPath = contextMenuPreviewIndexPath,
              let cell: IQCellActionsProvider = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let view: UIView = cell.contextMenuPreviewView(configuration: configuration) else {
            return nil
        }

        return UITargetedPreview(view: view)
    }

    func tableView(_ tableView: UITableView,
                   willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionCommitAnimating) {

        guard let indexPath: IndexPath = contextMenuPreviewIndexPath,
              let cell: IQCellActionsProvider = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider else {
            return
        }

        cell.performPreviewAction(configuration: configuration, animator: animator)
    }

    func tableView(_ tableView: UITableView,
                   previewForDismissingContextMenuWithConfiguration
                    configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard let indexPath: IndexPath = contextMenuPreviewIndexPath,
              let cell: IQCellActionsProvider = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let view: UIView = cell.contextMenuPreviewView(configuration: configuration) else {
            return nil
        }

        return UITargetedPreview(view: view)
    }
}
