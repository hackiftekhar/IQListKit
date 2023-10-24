//
//  IQCollectionViewDiffableDataSource+UICollectionViewDelegate.swift
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

@MainActor
extension IQCollectionViewDiffableDataSource: UICollectionViewDelegate {

    // MARK: - Selection

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {

        guard let item: IQItem = itemIdentifier(for: indexPath),
              let model: any IQSelectableModel = item.model as? any IQSelectableModel else {
            return true
        }

        return model.isHighlightable
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(collectionView, didHighlight: item, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(collectionView, didUnhighlight: item, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {

        guard let item: IQItem = itemIdentifier(for: indexPath),
              let model: any IQSelectableModel = item.model as? any IQSelectableModel else {
            return true
        }

        return model.isSelectable
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if clearsSelectionOnDidSelect {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(collectionView, didSelect: item, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {

        guard let item: IQItem = itemIdentifier(for: indexPath),
              let model: any IQSelectableModel = item.model as? any IQSelectableModel else {
            return true
        }

        return model.isDeselectable
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(collectionView, didDeselect: item, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        canPerformPrimaryActionForItemAt indexPath: IndexPath) -> Bool {

        guard let item: IQItem = itemIdentifier(for: indexPath),
              let model: any IQSelectableModel = item.model as? any IQSelectableModel else {
            return true
        }

        return model.canPerformPrimaryAction
    }

    func collectionView(_ collectionView: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) {
        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(collectionView, performPrimaryAction: item, at: indexPath)
    }

    // MARK: - Cell
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? any IQModelableCell {
            delegate?.listView(collectionView, willDisplay: cell, at: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? any IQModelableCell {
            delegate?.listView(collectionView, didEndDisplaying: cell, at: indexPath)
        }
    }

    // MARK: - Context menu
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {

        guard let indexPath = indexPaths.first,
              let cell: IQCellActionsProvider = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider,
              let configuration: UIContextMenuConfiguration = cell.contextMenuConfiguration() else {
            return nil
        }

        contextMenuPreviewIndexPath = indexPath
        return configuration
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {

        guard let cell: IQCellActionsProvider = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider,
              let configuration: UIContextMenuConfiguration = cell.contextMenuConfiguration() else {
            return nil
        }

        contextMenuPreviewIndexPath = indexPath
        return configuration
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplayContextMenu configuration: UIContextMenuConfiguration,
                        animator: UIContextMenuInteractionAnimating?) {

        guard let indexPath: IndexPath = contextMenuPreviewIndexPath,
              let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(collectionView, willDisplayContextMenu: configuration,
                           animator: animator, item: item, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
                        animator: UIContextMenuInteractionAnimating?) {

        guard let indexPath: IndexPath = contextMenuPreviewIndexPath,
              let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(collectionView, willEndContextMenuInteraction: configuration,
                           animator: animator, item: item, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration
                            configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard let indexPath: IndexPath = contextMenuPreviewIndexPath,
              let cell: IQCellActionsProvider = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider,
              let view: UIView = cell.contextMenuPreviewView(configuration: configuration) else {
            return nil
        }

        return UITargetedPreview(view: view)
    }

    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {

        guard let cell: IQCellActionsProvider = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider,
              let view: UIView = cell.contextMenuPreviewView(configuration: configuration) else {
            return nil
        }

        return UITargetedPreview(view: view)
    }

    func collectionView(_ collectionView: UICollectionView,
                        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                        animator: UIContextMenuInteractionCommitAnimating) {

        guard let indexPath = contextMenuPreviewIndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider else {
            return
        }

        cell.performPreviewAction(configuration: configuration, animator: animator)
    }

    func collectionView(_ collectionView: UICollectionView,
                        previewForDismissingContextMenuWithConfiguration
                            configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard let indexPath: IndexPath = contextMenuPreviewIndexPath,
              let cell: IQCellActionsProvider = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider,
              let view: UIView = cell.contextMenuPreviewView(configuration: configuration) else {
            return nil
        }

        return UITargetedPreview(view: view)
    }

    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {

        guard let cell: IQCellActionsProvider = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider,
              let view: UIView = cell.contextMenuPreviewView(configuration: configuration) else {
            return nil
        }

        return UITargetedPreview(view: view)
    }
}

// MARK: - Focus

@MainActor
extension IQCollectionViewDiffableDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        canFocusItemAt indexPath: IndexPath) -> Bool {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        return delegate?.collectionView?(collectionView, canFocusItemAt: indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView,
                        shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        return delegate?.collectionView?(collectionView, shouldUpdateFocusIn: context) ?? true
    }

    func collectionView(_ collectionView: UICollectionView,
                        didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
                        with coordinator: UIFocusAnimationCoordinator) {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        delegate?.collectionView?(collectionView, didUpdateFocusIn: context, with: coordinator)
    }

    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        return delegate?.indexPathForPreferredFocusedView?(in: collectionView)
    }

    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        selectionFollowsFocusForItemAt indexPath: IndexPath) -> Bool {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        return delegate?.collectionView?(collectionView,
                                         selectionFollowsFocusForItemAt: indexPath) ?? false
    }
}

// MARK: - Reordering
@MainActor
extension IQCollectionViewDiffableDataSource {

    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
                        atCurrentIndexPath currentIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        return delegate?.collectionView?(collectionView,
                                         targetIndexPathForMoveOfItemFromOriginalIndexPath: originalIndexPath,
                                         atCurrentIndexPath: currentIndexPath,
                                         toProposedIndexPath: proposedIndexPath) ?? proposedIndexPath
    }

    @available(iOS, introduced: 9.0, deprecated: 15.0)
    func collectionView(_ collectionView: UICollectionView,
                        targetIndexPathForMoveFromItemAt currentIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        return delegate?.collectionView?(collectionView,
                                         targetIndexPathForMoveFromItemAt: currentIndexPath,
                                         toProposedIndexPath: proposedIndexPath) ?? proposedIndexPath
    }

    func collectionView(_ collectionView: UICollectionView,
                        targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        let proposed = delegate?.collectionView?(collectionView,
                                                 targetContentOffsetForProposedContentOffset: proposedContentOffset)

        return proposed ?? proposedContentOffset
    }
}

// MARK: - Editing
@MainActor
extension IQCollectionViewDiffableDataSource {

    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        canEditItemAt indexPath: IndexPath) -> Bool {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        return delegate?.collectionView?(collectionView, canEditItemAt: indexPath) ?? false
    }
    func collectionView(_ collectionView: UICollectionView,
                        shouldSpringLoadItemAt indexPath: IndexPath,
                        with context: UISpringLoadedInteractionContext) -> Bool {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        return delegate?.collectionView?(collectionView,
                                         shouldSpringLoadItemAt: indexPath,
                                         with: context) ?? true
    }
}

// MARK: - Selection
@MainActor
extension IQCollectionViewDiffableDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        return delegate?.collectionView?(collectionView,
                                         shouldBeginMultipleSelectionInteractionAt: indexPath) ?? false
    }

    func collectionView(_ collectionView: UICollectionView,
                        didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        delegate?.collectionView?(collectionView,
                                  didBeginMultipleSelectionInteractionAt: indexPath)
    }

    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        delegate?.collectionViewDidEndMultipleSelectionInteraction?(collectionView)
    }

    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        sceneActivationConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIWindowScene.ActivationConfiguration? {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate
        return delegate?.collectionView?(collectionView,
                                         sceneActivationConfigurationForItemAt: indexPath,
                                         point: point)
    }
}
