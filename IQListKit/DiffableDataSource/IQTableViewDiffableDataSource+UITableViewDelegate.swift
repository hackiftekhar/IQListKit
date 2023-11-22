//
//  IQTableViewDiffableDataSource+UITableViewDelegate.swift
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

// swiftlint:disable file_length

@MainActor
extension IQTableViewDiffableDataSource: UITableViewDelegate {

    // MARK: - Height

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item: IQItem = itemIdentifier(for: indexPath),
                let type: IQViewSizeProvider.Type = item.type as? IQViewSizeProvider.Type else {
            return UITableView.automaticDimension
        }

        let itemSize: CGSize
        if let model = item.model as? AnyHashable,
           let size: CGSize = type.privateEstimatedSize(for: model, listView: tableView) {
            itemSize = size
        } else {
            itemSize = CGSize(width: tableView.frame.width, height: UITableView.automaticDimension)
        }

        return itemSize.height
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item: IQItem = itemIdentifier(for: indexPath),
                let type: IQViewSizeProvider.Type = item.type as? IQViewSizeProvider.Type else {
            return UITableView.automaticDimension
        }

        let itemSize: CGSize

        if let size: CGSize = dataSource?.listView(tableView, size: item, at: indexPath) {
            itemSize = size
        } else if let model = item.model as? AnyHashable,
                  let size: CGSize = type.privateSize(for: model, listView: tableView) {
            itemSize = size
        } else {
            itemSize = CGSize(width: tableView.frame.width, height: UITableView.automaticDimension)
        }

        return itemSize.height
    }
}

// MARK: - Configuring
@MainActor
extension IQTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {

        guard let item: IQItem = itemIdentifier(for: indexPath),
              let type: IQViewSizeProvider.Type = item.type as? IQViewSizeProvider.Type,
              let model = item.model as? AnyHashable else {
            return 0
        }

        return type.privateIndentationLevel(for: model, listView: tableView)
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
@MainActor
extension IQTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? any IQModelableCell {
            delegate?.listView(tableView, willDisplay: cell, at: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? any IQModelableCell {
            delegate?.listView(tableView, didEndDisplaying: cell, at: indexPath)
        }
    }
}

// MARK: - Selection

@MainActor
extension IQTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        guard let item: IQItem = itemIdentifier(for: indexPath),
              let model: any IQSelectableModel = item.model as? any IQSelectableModel else {
            return indexPath
        }

        return model.isSelectable ? indexPath : nil
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

        guard let item: IQItem = itemIdentifier(for: indexPath),
              let model: any IQSelectableModel = item.model as? any IQSelectableModel else {
            return indexPath
        }

        return model.isDeselectable ? indexPath : nil
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

@MainActor
extension IQTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return tableView.estimatedSectionHeaderHeight
        }

        let aSection: IQSection = sectionIdentifiers[section]

        let sectionSize: CGSize
        if let headerSize: CGSize = aSection.headerSize {
            sectionSize = headerSize
        } else if let type: IQViewSizeProvider.Type = aSection.headerType,
                  let headerModel = aSection.headerModel,
                  let size = type.privateEstimatedSize(for: headerModel, listView: tableView) {
            sectionSize = size
        } else {
            sectionSize = CGSize(width: tableView.frame.width, height: tableView.estimatedSectionHeaderHeight)
        }

        return sectionSize.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return tableView.estimatedSectionFooterHeight
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let sectionSize: CGSize
        if let footerSize: CGSize = aSection.footerSize {
            sectionSize = footerSize
        } else if let type: IQViewSizeProvider.Type = aSection.footerType,
                  let footerModel = aSection.footerModel,
                  let size = type.privateEstimatedSize(for: footerModel, listView: tableView) {
            sectionSize = size
        } else {
            sectionSize = CGSize(width: tableView.frame.width, height: tableView.estimatedSectionFooterHeight)
        }

        return sectionSize.height
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return tableView.sectionHeaderHeight
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let sectionSize: CGSize
        if let headerSize: CGSize = aSection.headerSize {
            sectionSize = headerSize
        } else if let type: IQViewSizeProvider.Type = aSection.headerType,
                  let headerModel = aSection.headerModel,
                  let size = type.privateSize(for: headerModel, listView: tableView) {
            sectionSize = size
        } else {
            sectionSize = CGSize(width: tableView.frame.width, height: tableView.sectionHeaderHeight)
        }

        return sectionSize.height
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return tableView.sectionFooterHeight
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let sectionSize: CGSize
        if let footerSize: CGSize = aSection.footerSize {
            sectionSize = footerSize
        } else if let type: IQViewSizeProvider.Type = aSection.footerType,
                  let footerModel = aSection.footerModel,
                  let size = type.privateSize(for: footerModel, listView: tableView) {
            sectionSize = size
        } else {
            sectionSize = CGSize(width: tableView.frame.width, height: tableView.sectionFooterHeight)
        }

        return sectionSize.height
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
                      let view = Bundle.main.loadNibNamed(identifier, owner: nil)?.first as? UIView,
                        type(of: view) == supplementaryType {
                supplementaryView = view
            } else {
                supplementaryView = supplementaryType.init()
            }

            if let supplementaryView = supplementaryView as? IQModelModifiable {
                if let headerModel = aSection.headerModel {
                    supplementaryView.privateSetModel(headerModel)
                }
            } else if supplementaryView != nil {
                print("""
                    '\(type(of: supplementaryType))' with identifier '\(identifier)' \
                    does not confirm to the '\(IQModelModifiable.self)' protocol
                    """)
            }
        } else {
            supplementaryView = dataSource?.listView(tableView, supplementaryElementFor: aSection,
                                                     kind: UICollectionView.elementKindSectionHeader,
                                                     at: indexPath)
        }

        guard let view = supplementaryView else { return nil }

        if let view: any IQModelableSupplementaryView = view as? any IQModelableSupplementaryView {
            delegate?.listView(tableView, modifySupplementaryElement: view, section: aSection,
                               kind: UICollectionView.elementKindSectionHeader, at: indexPath)
        }
        return view
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
                      let view = Bundle.main.loadNibNamed(identifier, owner: nil)?.first as? UIView,
                        type(of: view) == supplementaryType {
                supplementaryView = view
            } else {
                supplementaryView = supplementaryType.init()
            }

            if let supplementaryView = supplementaryView as? IQModelModifiable {
                if let footerModel = aSection.footerModel {
                    supplementaryView.privateSetModel(footerModel)
                }
            } else if supplementaryView != nil {
                print("""
                    '\(type(of: supplementaryType))' with identifier '\(identifier)' \
                    does not confirm to the '\(IQModelModifiable.self)' protocol
                    """)
            }
        } else {
            supplementaryView = dataSource?.listView(tableView, supplementaryElementFor: aSection,
                                                     kind: UICollectionView.elementKindSectionFooter,
                                                     at: indexPath)
        }

        guard let view = supplementaryView else { return nil }

        if let view: any IQModelableSupplementaryView = view as? any IQModelableSupplementaryView {
            delegate?.listView(tableView, modifySupplementaryElement: view, section: aSection,
                               kind: UICollectionView.elementKindSectionFooter, at: indexPath)
        }

        return view
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let indexPath: IndexPath = IndexPath(row: 0, section: section)

        if let view: any IQModelableSupplementaryView = view as? any IQModelableSupplementaryView {
            delegate?.listView(tableView, willDisplaySupplementaryElement: view, section: aSection,
                               kind: UICollectionView.elementKindSectionHeader, at: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let indexPath: IndexPath = IndexPath(row: 0, section: section)

        if let view: any IQModelableSupplementaryView = view as? any IQModelableSupplementaryView {
            delegate?.listView(tableView, didEndDisplayingSupplementaryElement: view, section: aSection,
                               kind: UICollectionView.elementKindSectionHeader, at: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let indexPath: IndexPath = IndexPath(row: 0, section: section)

        if let view: any IQModelableSupplementaryView = view as? any IQModelableSupplementaryView {
            delegate?.listView(tableView, willDisplaySupplementaryElement: view, section: aSection,
                               kind: UICollectionView.elementKindSectionFooter, at: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return
        }
        let aSection: IQSection = sectionIdentifiers[section]

        let indexPath: IndexPath = IndexPath(row: 0, section: section)

        if let view: any IQModelableSupplementaryView = view as? any IQModelableSupplementaryView {
            delegate?.listView(tableView, didEndDisplayingSupplementaryElement: view, section: aSection,
                               kind: UICollectionView.elementKindSectionFooter, at: indexPath)
        }
    }
}

// MARK: - Context menu
@MainActor
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
@MainActor
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

        guard let item: IQItem = itemIdentifier(for: indexPath),
              let model: any IQSelectableModel = item.model as? any IQSelectableModel else {
            return true
        }

        return model.canPerformPrimaryAction
    }

    func tableView(_ tableView: UITableView, performPrimaryActionForRowAt indexPath: IndexPath) {
        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(tableView, performPrimaryAction: item, at: indexPath)
    }
}

// MARK: - Highlights
@MainActor
extension IQTableViewDiffableDataSource {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {

        guard let item: IQItem = itemIdentifier(for: indexPath),
              let model: any IQSelectableModel = item.model as? any IQSelectableModel else {
            return true
        }

        return model.isHighlightable
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
@MainActor
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
        guard let item: IQItem = itemIdentifier(for: indexPath),
              let model: any IQReorderableModel = item.model as? any IQReorderableModel else {
            return .none
        }

        return model.editingStyle
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
@MainActor
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
@MainActor
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
// swiftlint:enable file_length
