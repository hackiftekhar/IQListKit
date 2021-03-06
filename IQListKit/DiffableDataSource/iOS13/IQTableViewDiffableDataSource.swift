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

@available(iOS 13.0, *)
internal final class IQTableViewDiffableDataSource: UITableViewDiffableDataSource<IQSection, IQItem> {

    weak var delegate: IQListViewDelegate?
    weak var dataSource: IQListViewDataSource?
    var clearsSelectionOnDidSelect = true

    private var contextMenuPreviewIndexPath: IndexPath?

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let aSection = snapshot().sectionIdentifiers[section]

        return aSection.header
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let aSection = snapshot().sectionIdentifiers[section]

        return aSection.footer
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        dataSource?.sectionIndexTitles(tableView)
    }
}

@available(iOS 13.0, *)
extension IQTableViewDiffableDataSource: UITableViewDelegate {

    // MARK: - Header Footer

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let aSection = snapshot().sectionIdentifiers[section]

        if let headerSize = aSection.headerSize {
            return headerSize.height
        } else if let headerView = aSection.headerView {
            return headerView.frame.height
        } else {
            return 22
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let aSection = snapshot().sectionIdentifiers[section]

        if let footerSize = aSection.footerSize {
            return footerSize.height
        } else if let footerView = aSection.footerView {
            return footerView.frame.height
        } else {
            return 22
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let aSection = snapshot().sectionIdentifiers[section]

        if let headerSize = aSection.headerSize {
            return headerSize.height
        } else if let headerView = aSection.headerView {
            return headerView.frame.height
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let aSection = snapshot().sectionIdentifiers[section]

        if let footerSize = aSection.footerSize {
            return footerSize.height
        } else if let footerView = aSection.footerView {
            return footerView.frame.height
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let aSection = snapshot().sectionIdentifiers[section]

        if let headerView = dataSource?.listView(tableView, headerFor: aSection, at: section) ?? aSection.headerView {
            delegate?.listView(tableView, modifyHeader: headerView, section: aSection, at: section)
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let aSection = snapshot().sectionIdentifiers[section]

        if let footerView = dataSource?.listView(tableView, footerFor: aSection, at: section) ?? aSection.footerView {
            delegate?.listView(tableView, modifyFooter: footerView, section: aSection, at: section)
            return footerView
        }
        return nil
    }

    // MARK: - Cell

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        if let item = itemIdentifier(for: indexPath), let type = item.type as? IQCellSizeProvider.Type {
            return type.estimatedSize(for: item.model, listView: tableView).height
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if let item = itemIdentifier(for: indexPath) {
            if let size = dataSource?.listView(tableView, size: item, at: indexPath) {
                return size.height
            } else if let type = item.type as? IQCellSizeProvider.Type {
                return type.size(for: item.model, listView: tableView).height
            }
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

        if let cell = tableView.cellForRow(at: indexPath) as? IQSelectableCell {
            return cell.isHighlightable
        }

        return true
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        if let cell = tableView.cellForRow(at: indexPath) as? IQSelectableCell {
            return cell.isSelectable ? indexPath : nil
        }

        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if clearsSelectionOnDidSelect {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        if let item = itemIdentifier(for: indexPath) {
            delegate?.listView(tableView, didSelect: item, at: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let item = itemIdentifier(for: indexPath) {
            delegate?.listView(tableView, didDeselect: item, at: indexPath)
        }
    }

    // MARK: - Swipe actions

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
           let swipeActions = cell.trailingSwipeActions() {

            var rowActions = [UITableViewRowAction]()

            for action in swipeActions {
                rowActions.append(action.rowAction())
            }

            return rowActions
        }

        return nil
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
           let swipeActions = cell.leadingSwipeActions() {
            var contextualSwipeActions = [UIContextualAction]()

            for action in swipeActions {
                contextualSwipeActions.append(action.contextualAction())
            }

            return UISwipeActionsConfiguration(actions: contextualSwipeActions)
        }

        return nil
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
           let swipeActions = cell.trailingSwipeActions() {
            var contextualSwipeActions = [UIContextualAction]()

            for action in swipeActions {
                contextualSwipeActions.append(action.contextualAction())
            }

            return UISwipeActionsConfiguration(actions: contextualSwipeActions)
        }

        return nil
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {

        if let item = itemIdentifier(for: indexPath),
           let type = item.type as? IQCellSizeProvider.Type {
            return type.indentationLevel(for: item.model, listView: tableView)
        }

        return 0
    }

    // MARK: - Context menu

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {

        if let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
           let configuration = cell.contextMenuConfiguration() {
            contextMenuPreviewIndexPath = indexPath
            return configuration
        }

        return nil
    }

    func tableView(_ tableView: UITableView,
                   previewForHighlightingContextMenuWithConfiguration
                    configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        if let indexPath = contextMenuPreviewIndexPath,
           let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
           let view = cell.contextMenuPreviewView(configuration: configuration) {
            return UITargetedPreview(view: view)
        }
        return nil
    }

    func tableView(_ tableView: UITableView,
                   willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionCommitAnimating) {

        if let indexPath = contextMenuPreviewIndexPath,
           let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider {
            cell.performPreviewAction(configuration: configuration, animator: animator)
        }
    }

    func tableView(_ tableView: UITableView,
                   previewForDismissingContextMenuWithConfiguration
                    configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        if let indexPath = contextMenuPreviewIndexPath,
           let cell = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
           let view = cell.contextMenuPreviewView(configuration: configuration) {
            return UITargetedPreview(view: view)
        }
        return nil
    }
}

// public protocol UITableViewDataSource : NSObjectProtocol {
//    // Moving/reordering
//
//    // Allows the reorder accessory view to optionally be shown for a particular row.
// By default, the reorder control will be shown only if the datasource implements
// -tableView:moveRowAtIndexPath:toIndexPath:
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
//
//
//    // Data manipulation - insert and delete support
//
//    // After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell),
// the dataSource must commit the change
//    // Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView,
// commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
//
//
//    // Data manipulation - reorder / moving support
//
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView,
// moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
// }

// public protocol UITableViewDelegate : UIScrollViewDelegate {
//
//
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
//
//    @available(iOS 9.0, *)
//    optional func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool
//
//    @available(iOS 9.0, *)
//    optional func tableView(_ tableView: UITableView,
// shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool
//
//    @available(iOS 9.0, *)
//    optional func tableView(_ tableView: UITableView,
// didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
//
//    @available(iOS 9.0, *)
//    optional func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?
//
//    @available(iOS 11.0, *)
//    optional func tableView(_ tableView: UITableView,
// shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool
//
//    @available(iOS 13.0, *)
//    optional func tableView(_ tableView: UITableView,
// shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool
//
//    @available(iOS 13.0, *)
//    optional func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath)
//
//    @available(iOS 13.0, *)
//    optional func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView)
// }
