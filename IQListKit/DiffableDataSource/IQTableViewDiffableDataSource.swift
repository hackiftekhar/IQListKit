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
    internal var registeredSupplementaryViews: [String: [UIView.Type]] = [:]

    weak var proxyDelegate: IQListViewProxyDelegate?
    weak var delegate: IQListViewDelegate?
    weak var dataSource: IQListViewDataSource?
    var clearsSelectionOnDidSelect = true
    private var contextMenuPreviewIndexPath: IndexPath?

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
}

extension IQTableViewDiffableDataSource: UITableViewDelegate {


    // MARK: - Height

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
}

// MARK: - Configuring
extension IQTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {

        guard let item: IQItem = itemIdentifier(for: indexPath),
              let type: IQViewSizeProvider.Type = item.type as? IQViewSizeProvider.Type else {
            return 0
        }

        return type.indentationLevel(for: item.model, listView: tableView)
    }

    func tableView(_ tableView: UITableView,
                   shouldSpringLoadRowAt indexPath: IndexPath,
                   with context: UISpringLoadedInteractionContext) -> Bool {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        return delegate?.tableView?(tableView,
                                    shouldSpringLoadRowAt: indexPath,
                                    with: context) ?? true
    }
}

// MARK: - Display
extension IQTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.listView(tableView, willDisplay: cell, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.listView(tableView, didEndDisplaying: cell, at: indexPath)
    }

}

// MARK: - Selection

extension IQTableViewDiffableDataSource {

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

    func tableView(_ tableView: UITableView,
                   accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        delegate?.tableView?(tableView,
                             accessoryButtonTappedForRowWith: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        return delegate?.tableView?(tableView,
                                    shouldBeginMultipleSelectionInteractionAt: indexPath) ?? false
    }

    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        delegate?.tableView?(tableView, didBeginMultipleSelectionInteractionAt: indexPath)
    }

    func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        delegate?.tableViewDidEndMultipleSelectionInteraction?(tableView)
    }
}

// MARK: - Header Footer / Supplementary view

extension IQTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return tableView.estimatedSectionHeaderHeight
        }

        let aSection: IQSection = sectionIdentifiers[section]

        if let headerSize: CGSize = aSection.headerSize {
            return headerSize.height
        } else if let headerView: UIView = aSection.headerView {
            return headerView.frame.height
        } else {
            guard let type: IQViewSizeProvider.Type = aSection.headerType as? IQViewSizeProvider.Type else {
                return tableView.estimatedSectionHeaderHeight
            }

            return type.estimatedSize(for: aSection.headerModel, listView: tableView).height
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return tableView.estimatedSectionFooterHeight
        }
        let aSection: IQSection = sectionIdentifiers[section]

        if let footerSize: CGSize = aSection.footerSize {
            return footerSize.height
        } else if let footerView: UIView = aSection.footerView {
            return footerView.frame.height
        } else {
            guard let type: IQViewSizeProvider.Type = aSection.footerModel as? IQViewSizeProvider.Type else {
                return tableView.estimatedSectionFooterHeight
            }

            return type.estimatedSize(for: aSection.footerModel, listView: tableView).height
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return tableView.estimatedSectionHeaderHeight
        }
        let aSection: IQSection = sectionIdentifiers[section]

        if let headerSize: CGSize = aSection.headerSize {
            return headerSize.height
        } else if let headerView: UIView = aSection.headerView {
            return headerView.frame.height
        } else {
            guard let type: IQViewSizeProvider.Type = aSection.headerType as? IQViewSizeProvider.Type else {
                return tableView.sectionHeaderHeight
            }

            return type.size(for: aSection.headerModel, listView: tableView).height
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return tableView.estimatedSectionFooterHeight
        }
        let aSection: IQSection = sectionIdentifiers[section]

        if let footerSize: CGSize = aSection.footerSize {
            return footerSize.height
        } else if let footerView: UIView = aSection.footerView {
            return footerView.frame.height
        } else {
            guard let type: IQViewSizeProvider.Type = aSection.footerModel as? IQViewSizeProvider.Type else {
                return tableView.sectionFooterHeight
            }

            return type.size(for: aSection.footerModel, listView: tableView).height
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return nil
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let indexPath: IndexPath = IndexPath(row: 0, section: section)

        let supplementaryView: UIView?
        if let supplementaryType = aSection.headerType, !(supplementaryType is IQSupplementaryViewPlaceholder.Type) {
            let identifier = String(describing: supplementaryType)

            if supplementaryType is UITableViewHeaderFooterView.Type {
                supplementaryView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
            } else if Bundle.main.path(forResource: identifier, ofType: "nib") != nil,
                      let view = Bundle.main.loadNibNamed(identifier, owner: nil)?.first as? UIView, type(of: view) == supplementaryType {
                supplementaryView = view
            } else {
                supplementaryView = supplementaryType.init()
            }

            if let supplementaryView = supplementaryView as? IQModelModifiable {
                supplementaryView.setModel(aSection.headerModel)
            } else if supplementaryView != nil {
                print("""
                    \(type(of: supplementaryType)) with identifier \(identifier) \
                    does not confirm to the \(IQModelModifiable.self) protocol
                    """)
            }
        } else if let headerView = aSection.headerView {
            supplementaryView = headerView
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
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return nil
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let indexPath: IndexPath = IndexPath(row: 0, section: section)

        let supplementaryView: UIView?
        if let supplementaryType = aSection.footerType, !(supplementaryType is IQSupplementaryViewPlaceholder.Type) {
            let identifier = String(describing: supplementaryType)

            if supplementaryType is UITableViewHeaderFooterView.Type {
                supplementaryView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
            } else if Bundle.main.path(forResource: identifier, ofType: "nib") != nil,
                      let view = Bundle.main.loadNibNamed(identifier, owner: nil)?.first as? UIView, type(of: view) == supplementaryType {
                supplementaryView = view
            } else {
                supplementaryView = supplementaryType.init()
            }

            if let supplementaryView = supplementaryView as? IQModelModifiable {
                supplementaryView.setModel(aSection.footerModel)
            } else if supplementaryView != nil {
                print("""
                    \(type(of: supplementaryType)) with identifier \(identifier) \
                    does not confirm to the \(IQModelModifiable.self) protocol
                    """)
            }
        } else if let footerView = aSection.footerView {
            supplementaryView = footerView
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
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let indexPath: IndexPath = IndexPath(row: 0, section: section)
        delegate?.listView(tableView, willDisplaySupplementaryElement: view, section: aSection,
                           kind: UICollectionView.elementKindSectionHeader, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let indexPath: IndexPath = IndexPath(row: 0, section: section)
        delegate?.listView(tableView, didEndDisplayingSupplementaryElement: view, section: aSection,
                           kind: UICollectionView.elementKindSectionHeader, at: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let indexPath: IndexPath = IndexPath(row: 0, section: section)
        delegate?.listView(tableView, willDisplaySupplementaryElement: view, section: aSection,
                           kind: UICollectionView.elementKindSectionFooter, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let indexPath: IndexPath = IndexPath(row: 0, section: section)
        delegate?.listView(tableView, didEndDisplayingSupplementaryElement: view, section: aSection,
                           kind: UICollectionView.elementKindSectionFooter, at: indexPath)
    }
}

// MARK: - Context menu
extension IQTableViewDiffableDataSource {

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

// MARK: - Swipe actions
extension IQTableViewDiffableDataSource {

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
}

// MARK: - Highlights
extension IQTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {

        guard let cell: IQSelectableCell = tableView.cellForRow(at: indexPath) as? IQSelectableCell else {
            return true
        }

        return cell.isHighlightable
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
}

// MARK: - Editing
extension IQTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView,
                   willBeginEditingRowAt indexPath: IndexPath) {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        delegate?.tableView?(tableView, willBeginEditingRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        delegate?.tableView?(tableView, didEndEditingRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {

        guard let cell: IQReorderableCell = tableView.cellForRow(at: indexPath) as? IQReorderableCell else {
            return .none
        }

        return cell.editingStyle
    }

    func tableView(_ tableView: UITableView,
                   titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        return delegate?.tableView?(tableView,
                                    titleForDeleteConfirmationButtonForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        return delegate?.tableView?(tableView,
                                    shouldIndentWhileEditingRowAt: indexPath) ?? false
    }
}

// MARK: - Reordering
extension IQTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView,
                   targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        return delegate?.tableView?(tableView,
                                    targetIndexPathForMoveFromRowAt: sourceIndexPath,
                                    toProposedIndexPath: proposedDestinationIndexPath) ?? proposedDestinationIndexPath
    }

}

// MARK: - Focus
extension IQTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView,
                   canFocusRowAt indexPath: IndexPath) -> Bool {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        return delegate?.tableView?(tableView, canFocusRowAt: indexPath) ?? true
    }

    func tableView(_ tableView: UITableView,
                   shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        return delegate?.tableView?(tableView, shouldUpdateFocusIn: context) ?? true
    }

    func tableView(_ tableView: UITableView,
                   didUpdateFocusIn context: UITableViewFocusUpdateContext,
                   with coordinator: UIFocusAnimationCoordinator) {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        delegate?.tableView?(tableView, didUpdateFocusIn: context, with: coordinator)
    }

    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        return delegate?.indexPathForPreferredFocusedView?(in: tableView)
    }

    @available(iOS 15.0, *)
    func tableView(_ tableView: UITableView,
                   selectionFollowsFocusForRowAt indexPath: IndexPath) -> Bool {
        let delegate: UITableViewDelegate? = delegate as? UITableViewDelegate
        return delegate?.tableView?(tableView,
                                    selectionFollowsFocusForRowAt: indexPath) ?? false
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
