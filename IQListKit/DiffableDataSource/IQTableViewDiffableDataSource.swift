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

// swiftlint:disable file_length
internal final class IQTableViewDiffableDataSource: UITableViewDiffableDataSource<IQSection, IQItem> {

    internal var registeredCells: [IQListCell.Type] = []
    internal var registeredSupplementaryViews: [String: IQListSupplementaryView.Type] = [:]

    weak var proxyDelegate: IQListViewProxyDelegate?
    weak var delegate: IQListViewDelegate?
    weak var dataSource: IQListViewDataSource?
    var clearsSelectionOnDidSelect = true
    private var contextMenuPreviewIndexPath: IndexPath?

    override init(tableView: UITableView, cellProvider: @escaping IQTableViewDiffableDataSource.CellProvider) {
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section: IQSection = snapshot().sectionIdentifiers[section]
        guard section.headerType is IQSupplementaryViewPlaceholder.Type else {
            return nil
        }
        return section.headerModel as? String
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section: IQSection = snapshot().sectionIdentifiers[section]
        guard section.footerType is IQSupplementaryViewPlaceholder.Type else {
            return nil
        }
        return section.footerModel as? String
    }

    // MARK: - Editing

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return false
        }

         if let canEdit = dataSource?.listView(tableView, canEdit: item, at: indexPath) {
            return canEdit
        } else if let cell: IQReorderableCell = tableView.cellForRow(at: indexPath) as? IQReorderableCell {
            return cell.canEdit
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

         if let canMove = dataSource?.listView(tableView, canMove: item, at: indexPath) {
            return canMove
        } else if let cell: IQReorderableCell = tableView.cellForRow(at: indexPath) as? IQReorderableCell {
            return cell.canMove
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

    // MARK: - Moving/reordering
}

extension IQTableViewDiffableDataSource: UITableViewDelegate {

    // MARK: - Supplementary view

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let section: IQSection = snapshot().sectionIdentifiers[section]

        guard let type: IQViewSizeProvider.Type = section.headerType as? IQViewSizeProvider.Type else {
            return tableView.estimatedSectionHeaderHeight
        }

        return type.estimatedSize(for: section.headerModel, listView: tableView).height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let section: IQSection = snapshot().sectionIdentifiers[section]

        guard let type: IQViewSizeProvider.Type = section.footerType as? IQViewSizeProvider.Type else {
            return tableView.estimatedSectionHeaderHeight
        }

        return type.estimatedSize(for: section.footerModel, listView: tableView).height
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section: IQSection = snapshot().sectionIdentifiers[section]

        guard let type: IQViewSizeProvider.Type = section.headerType as? IQViewSizeProvider.Type else {
            return tableView.estimatedSectionHeaderHeight
        }

        return type.size(for: section.headerModel, listView: tableView).height
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section: IQSection = snapshot().sectionIdentifiers[section]

        guard let type: IQViewSizeProvider.Type = section.footerType as? IQViewSizeProvider.Type else {
            return tableView.estimatedSectionHeaderHeight
        }

        return type.size(for: section.footerModel, listView: tableView).height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let aSection: IQSection = snapshot().sectionIdentifiers[section]
        let indexPath: IndexPath = IndexPath(row: 0, section: section)

        let supplementaryView: IQListSupplementaryView?
        if let supplementaryType = aSection.headerType {
            let identifier = String(describing: supplementaryType)

            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
            if let view = view as? IQModelModifiable {
                view.setModel(aSection.headerModel)
            } else {
                print("""
                    \(type(of: supplementaryType)) with identifier \(identifier) \
                    does not confirm to the \(IQModelModifiable.self) protocol
                    """)
            }
            supplementaryView = view
        } else {
            supplementaryView = dataSource?.listView(tableView, supplementaryElementFor: aSection,
                                                     kind: UICollectionView.elementKindSectionHeader,
                                                     at: indexPath)
        }

        guard let supplementaryView = supplementaryView else { return nil }
        delegate?.listView(tableView, modifySupplementaryElement: supplementaryView, section: aSection,
                           kind: UICollectionView.elementKindSectionHeader, at: indexPath)
        return supplementaryView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let aSection: IQSection = snapshot().sectionIdentifiers[section]
        let indexPath: IndexPath = IndexPath(row: 0, section: section)

        let supplementaryView: IQListSupplementaryView?
        if let supplementaryType = aSection.footerType {
            let identifier = String(describing: supplementaryType)

            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
            if let view = view as? IQModelModifiable {
                view.setModel(aSection.headerModel)
            } else {
                print("""
                    \(type(of: supplementaryType)) with identifier \(identifier) \
                    does not confirm to the \(IQModelModifiable.self) protocol
                    """)
            }
            supplementaryView = view
        } else {
            supplementaryView = dataSource?.listView(tableView, supplementaryElementFor: aSection,
                                                     kind: UICollectionView.elementKindSectionFooter,
                                                     at: indexPath)
        }

        guard let supplementaryView = supplementaryView else { return nil }
        delegate?.listView(tableView, modifySupplementaryElement: supplementaryView, section: aSection,
                           kind: UICollectionView.elementKindSectionFooter, at: indexPath)
        return supplementaryView
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let aSection: IQSection = snapshot().sectionIdentifiers[section]
        let indexPath: IndexPath = IndexPath(row: 0, section: section)
        guard let view = view as? IQListSupplementaryView else { return }
        delegate?.listView(tableView, willDisplaySupplementaryElement: view, section: aSection,
                           kind: UICollectionView.elementKindSectionHeader, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        let aSection: IQSection = snapshot().sectionIdentifiers[section]
        let indexPath: IndexPath = IndexPath(row: 0, section: section)
        guard let view = view as? IQListSupplementaryView else { return }
        delegate?.listView(tableView, didEndDisplayingSupplementaryElement: view, section: aSection,
                           kind: UICollectionView.elementKindSectionHeader, at: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let aSection: IQSection = snapshot().sectionIdentifiers[section]
        let indexPath: IndexPath = IndexPath(row: 0, section: section)
        guard let view = view as? IQListSupplementaryView else { return }
        delegate?.listView(tableView, willDisplaySupplementaryElement: view, section: aSection,
                           kind: UICollectionView.elementKindSectionFooter, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        let aSection: IQSection = snapshot().sectionIdentifiers[section]
        let indexPath: IndexPath = IndexPath(row: 0, section: section)
        guard let view = view as? IQListSupplementaryView else { return }
        delegate?.listView(tableView, didEndDisplayingSupplementaryElement: view, section: aSection,
                           kind: UICollectionView.elementKindSectionFooter, at: indexPath)
    }

    // MARK: - Cell

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item: IQItem = itemIdentifier(for: indexPath),
                let type: IQViewSizeProvider.Type = item.type as? IQViewSizeProvider.Type else {
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
        } else if let type: IQViewSizeProvider.Type = item.type as? IQViewSizeProvider.Type {
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
              let type: IQViewSizeProvider.Type = item.type as? IQViewSizeProvider.Type else {
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

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let cell: IQSelectableCell = tableView.cellForRow(at: indexPath) as? IQSelectableCell else {
            return indexPath
        }

        return cell.isDeselectable ? indexPath : nil
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(tableView, didDeselect: item, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(tableView, didHighlight: item, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(tableView, didUnhighlight: item, at: indexPath)
    }

    func tableView(_ tableView: UITableView, canPerformPrimaryActionForRowAt indexPath: IndexPath) -> Bool {

        guard let cell: IQSelectableCell = tableView.cellForRow(at: indexPath) as? IQSelectableCell else {
            return true
        }

        return cell.canPerformPrimaryAction
    }

    func tableView(_ tableView: UITableView, performPrimaryActionForRowAt indexPath: IndexPath) {
        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(tableView, performPrimaryAction: item, at: indexPath)
    }

    // MARK: - Swipe actions
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {

        guard let cell: IQReorderableCell = tableView.cellForRow(at: indexPath) as? IQReorderableCell else {
            return .none
        }

        return cell.editingStyle
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard let cell: IQCellActionsProvider = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let swipeActions: [UIContextualAction] = cell.leadingSwipeActions() else {
            return nil
        }

        return UISwipeActionsConfiguration(actions: swipeActions)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard let cell: IQCellActionsProvider = tableView.cellForRow(at: indexPath) as? IQCellActionsProvider,
              let swipeActions: [UIContextualAction] = cell.trailingSwipeActions() else {
            return nil
        }

        return UISwipeActionsConfiguration(actions: swipeActions)
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

    func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionAnimating?) {

        guard let indexPath: IndexPath = contextMenuPreviewIndexPath,
              let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(tableView, willDisplayContextMenu: configuration,
                           animator: animator, item: item, at: indexPath)
    }

    func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionAnimating?) {

        guard let indexPath: IndexPath = contextMenuPreviewIndexPath,
              let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(tableView, willEndContextMenuInteraction: configuration,
                           animator: animator, item: item, at: indexPath)
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

extension IQTableViewDiffableDataSource: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        var items: [IQItem] = []
        var itemIndexPaths: [IndexPath] = []

        indexPaths.forEach { indexPath in
            if let item: IQItem = itemIdentifier(for: indexPath) {
                items.append(item)
                itemIndexPaths.append(indexPath)
            }
        }

        dataSource?.listView(tableView, prefetch: items, at: itemIndexPaths)
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        var items: [IQItem] = []
        var itemIndexPaths: [IndexPath] = []

        indexPaths.forEach { indexPath in
            if let item: IQItem = itemIdentifier(for: indexPath) {
                items.append(item)
                itemIndexPaths.append(indexPath)
            }
        }

        dataSource?.listView(tableView, cancelPrefetch: items, at: itemIndexPaths)
    }
}

// {
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
//
//    @available(iOS 3.0, *)
//    optional func tableView(_ tableView: UITableView,
//    titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
//
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool
//
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)
//
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)
//
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
//    toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
//
//    @available(iOS 9.0, *)
//    optional func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool
//
//    @available(iOS 9.0, *)
//    optional func tableView(_ tableView: UITableView,
//    shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool
//
//    @available(iOS 9.0, *)
//    optional func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext,
//    with coordinator: UIFocusAnimationCoordinator)
//
//    @available(iOS 9.0, *)
//    optional func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?
//
//    /// Determines if the row at the specified index path should also become selected when focus moves to it.
//    /// If the table view's global selectionFollowsFocus is enabled, this method will allow you to override that
//    /// behavior on a per-index path basis. This method is not called if selectionFollowsFocus is disabled.
//    @available(iOS 15.0, *)
//    optional func tableView(_ tableView: UITableView, selectionFollowsFocusForRowAt indexPath: IndexPath) -> Bool
//
//    @available(iOS 11.0, *)
//    optional func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath,
//    with context: UISpringLoadedInteractionContext) -> Bool
//
//    @available(iOS 13.0, *)
//    optional func tableView(_ tableView: UITableView,
//    shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool
//
//    @available(iOS 13.0, *)
//    optional func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath)
//
//    @available(iOS 13.0, *)
//    optional func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView)
//
//
//    /**
//     * @abstract Called when the table view is about to display a menu.
//     *
//     * @param tableView       This UITableView.
//     * @param configuration   The configuration of the menu about to be displayed.
//     * @param animator        Appearance animator. Add animations to run them alongside the appearance transition.
//     */
//    @available(iOS 14.0, *)
//
// }

// {
//    @available(iOS 2.0, *)
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//
//
//    // Row display. Implementers should *always* try to reuse cells by setting each cell's
//    // reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
//    // Cell gets various attributes set automatically based on table (separators)
//    and data source (accessory views, editing controls)
//
//    @available(iOS 2.0, *)
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
//
//
//    @available(iOS 2.0, *)
//    optional func numberOfSections(in tableView: UITableView) -> Int // Default is 1 if not implemented
//
//
//    fixed font style. use custom view (UILabel) if you want something different
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
//
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
//
//
//    // Editing
//
//    // Individual rows can opt out of having the -editing property set for them. If not implemented,
//    all rows are assumed to be editable.
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
//
//
//    // Moving/reordering
//
//    // Allows the reorder accessory view to optionally be shown for a particular row. By default,
//    the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
//
//
//    // Index
//    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
//    @available(iOS 2.0, *)
//    optional func sectionIndexTitles(for tableView: UITableView) -> [String]?
//
//     // tell table which section corresponds to section title/index (e.g. "B",1))
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
//
//
//    // Data manipulation - insert and delete support
//
//    // After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell),
//    // the dataSource must commit the change
//    // Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
//    forRowAt indexPath: IndexPath)
//
//
//    // Data manipulation - reorder / moving support
//
//    @available(iOS 2.0, *)
//    optional func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
//    to destinationIndexPath: IndexPath)
