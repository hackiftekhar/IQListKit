//
//  IQCommonTableViewDiffableDataSource.swift
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

final class IQCommonTableViewDiffableDataSource {

    weak var delegate: IQListViewDelegate?
    weak var dataSource: IQListViewDataSource?
    var clearsSelectionOnDidSelect = true
    private var contextMenuPreviewIndexPath: IndexPath?

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: IQSection) -> String? {
        return section.header
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: IQSection) -> String? {
        return section.footer
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        dataSource?.sectionIndexTitles(tableView)
    }
}

extension IQCommonTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: IQSection) -> CGFloat {
        if let headerSize = section.headerSize {
            return headerSize.height
        } else if let headerView = section.headerView {
            return headerView.frame.height
        } else if section.header != nil {
            return tableView.sectionHeaderHeight
        } else {
            return tableView.estimatedSectionHeaderHeight
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: IQSection) -> CGFloat {
        if let footerSize = section.footerSize {
            return footerSize.height
        } else if let footerView = section.footerView {
            return footerView.frame.height
        } else if section.footer != nil {
            return tableView.sectionFooterHeight
        } else {
            return tableView.estimatedSectionFooterHeight
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: IQSection) -> CGFloat {
        if let headerSize = section.headerSize {
            return headerSize.height
        } else if let headerView = section.headerView {
            return headerView.frame.height
        } else if section.header != nil {
            return tableView.sectionHeaderHeight
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: IQSection) -> CGFloat {
        if let footerSize = section.footerSize {
            return footerSize.height
        } else if let footerView = section.footerView {
            return footerView.frame.height
        } else if section.footer != nil {
            return tableView.sectionFooterHeight
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionIndex: Int, section: IQSection) -> UIView? {

        let view = dataSource?.listView(tableView, headerFor: section, at: sectionIndex)
        if let headerView = view ?? section.headerView {
            delegate?.listView(tableView, modifyHeader: headerView, section: section, at: sectionIndex)
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection sectionIndex: Int, section: IQSection) -> UIView? {

        let view = dataSource?.listView(tableView, footerFor: section, at: sectionIndex)
        if let footerView = view ?? section.footerView {
            delegate?.listView(tableView, modifyFooter: footerView, section: section, at: sectionIndex)
            return footerView
        }
        return nil
    }

    // MARK: - Cell

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt item: IQItem?) -> CGFloat {

        guard let item = item, let type = item.type as? IQCellSizeProvider.Type else {
            return UITableView.automaticDimension
        }
        return type.estimatedSize(for: item.model, listView: tableView).height
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, item: IQItem?) -> CGFloat {

        guard let item = item else {
            return UITableView.automaticDimension
        }

        if let size = dataSource?.listView(tableView, size: item, at: indexPath) {
            return size.height
        } else if let type = item.type as? IQCellSizeProvider.Type {
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

    // MARK: - Selection

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {

        guard let cell = tableView.cellForRow(at: indexPath) as? IQSelectableCell else {
            return true
        }

        return cell.isHighlightable
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        guard let cell = tableView.cellForRow(at: indexPath) as? IQSelectableCell else {
            return indexPath
        }

        return cell.isSelectable ? indexPath : nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, item: IQItem?) {

        if clearsSelectionOnDidSelect {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        guard let item = item else { return }

        delegate?.listView(tableView, didSelect: item, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath, item: IQItem?) {

        guard let item = item else { return }

        delegate?.listView(tableView, didDeselect: item, at: indexPath)
    }

    // MARK: - Swipe actions
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if #available(iOS 11.0, *) {
            return .none
        } else {

            guard let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider else { return .none }

            if cell.trailingSwipeActions() != nil {
                // editActionsForRowAt does not getting called if we provide .none
                // So adding it as a workaround, the delete button will not be shown btw
                return .delete
            } else {
                return .none
            }
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        guard let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let swipeActions = cell.trailingSwipeActions() else {
            return nil
        }

        var rowActions = [UITableViewRowAction]()

        for action in swipeActions {
            rowActions.append(action.rowAction())
        }

        return rowActions
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let swipeActions = cell.leadingSwipeActions() else {
            return nil
        }

        var contextualSwipeActions = [UIContextualAction]()

        for action in swipeActions {
            contextualSwipeActions.append(action.contextualAction())
        }

        return UISwipeActionsConfiguration(actions: contextualSwipeActions)
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let swipeActions = cell.trailingSwipeActions() else {
            return nil
        }

        var contextualSwipeActions = [UIContextualAction]()

        for action in swipeActions {
            contextualSwipeActions.append(action.contextualAction())
        }

        return UISwipeActionsConfiguration(actions: contextualSwipeActions)
    }

    // MARK: - Context menu

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {

        guard let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let configuration = cell.contextMenuConfiguration() else {
            return nil
        }

        contextMenuPreviewIndexPath = indexPath
        return configuration
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView,
                   previewForHighlightingContextMenuWithConfiguration
                    configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard let indexPath = contextMenuPreviewIndexPath,
              let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let view = cell.contextMenuPreviewView(configuration: configuration) else {
            return nil
        }

        return UITargetedPreview(view: view)
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView,
                   willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionCommitAnimating) {

        guard let indexPath = contextMenuPreviewIndexPath,
              let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider else {
            return
        }

        cell.performPreviewAction(configuration: configuration, animator: animator)
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView,
                   previewForDismissingContextMenuWithConfiguration
                    configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard let indexPath = contextMenuPreviewIndexPath,
              let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let view = cell.contextMenuPreviewView(configuration: configuration) else {
            return nil
        }

        return UITargetedPreview(view: view)
    }
}
