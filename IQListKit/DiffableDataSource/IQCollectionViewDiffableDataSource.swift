//
//  IQCollectionViewDiffableDataSource.swift
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

// MARK: - Improved DiffableDataSource of UICollectionView

// swiftlint:disable file_length
internal final class IQCollectionViewDiffableDataSource: UICollectionViewDiffableDataSource<IQSection, IQItem> {

    private var contextMenuPreviewIndexPath: IndexPath?

    weak var proxyDelegate: IQListViewProxyDelegate?
    weak var delegate: IQListViewDelegate?
    weak var dataSource: IQListViewDataSource?
    var clearsSelectionOnDidSelect: Bool = true

    // MARK: - Header Footer

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {

        let section: IQSection = snapshot().sectionIdentifiers[indexPath.section]

        if kind.elementsEqual(UICollectionView.elementKindSectionHeader) {
            let reusableView: UICollectionReusableView

            let headerView: UIView? = dataSource?.listView(collectionView,
                                                           headerFor: section,
                                                           at: indexPath.section) ?? section.headerView

            if let headerView: UICollectionReusableView = headerView as? UICollectionReusableView {
                reusableView = headerView
            } else if let headerView = headerView {
                let sHeader = collectionView.dequeue(UICollectionReusableView.self, kind: kind, for: indexPath)
                sHeader.frame = headerView.bounds
                sHeader.addSubview(headerView)
                reusableView = sHeader
            } else if let header: String = section.header {
                let sHeader = collectionView.dequeue(IQCollectionViewHeaderFooter.self, kind: kind, for: indexPath)
                sHeader.textLabel.text = header
                reusableView = sHeader
            } else {
                reusableView = collectionView.dequeue(UICollectionReusableView.self, kind: kind, for: indexPath)
            }

            delegate?.listView(collectionView, modifyHeader: reusableView, section: section, at: indexPath.section)

            return reusableView
        } else if kind.elementsEqual(UICollectionView.elementKindSectionFooter) {
            let reusableView: UICollectionReusableView

            let footerView: UIView? = dataSource?.listView(collectionView,
                                                           footerFor: section,
                                                           at: indexPath.section) ?? section.footerView

            if let footerView: UICollectionReusableView = footerView as? UICollectionReusableView {
                reusableView = footerView
            } else if let footerView: UIView = footerView {
                let sFooter = collectionView.dequeue(UICollectionReusableView.self, kind: kind, for: indexPath)
                sFooter.frame = footerView.bounds
                sFooter.addSubview(footerView)
                reusableView = sFooter
            } else if let footer: String = section.footer {
                let sFooter = collectionView.dequeue(IQCollectionViewHeaderFooter.self, kind: kind, for: indexPath)
                sFooter.textLabel.text = footer
                reusableView = sFooter
            } else {
                reusableView = collectionView.dequeue(UICollectionReusableView.self, kind: kind, for: indexPath)
            }

            delegate?.listView(collectionView, modifyFooter: reusableView, section: section, at: indexPath.section)

            return reusableView
        } else {
            return collectionView.dequeue(UICollectionReusableView.self, kind: kind, for: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String, at indexPath: IndexPath) {
        let aSection: IQSection = snapshot().sectionIdentifiers[indexPath.section]
        if elementKind.elementsEqual(UICollectionView.elementKindSectionHeader) {
            delegate?.listView(collectionView, willDisplayHeaderView: view, section: aSection, at: indexPath.section)
        } else if elementKind.elementsEqual(UICollectionView.elementKindSectionFooter) {
            delegate?.listView(collectionView, willDisplayFooterView: view, section: aSection, at: indexPath.section)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplayingSupplementaryView view: UICollectionReusableView,
                        forElementOfKind elementKind: String, at indexPath: IndexPath) {
        let aSection: IQSection = snapshot().sectionIdentifiers[indexPath.section]
        if elementKind.elementsEqual(UICollectionView.elementKindSectionHeader) {
            delegate?.listView(collectionView, didEndDisplayingHeaderView: view,
                               section: aSection, at: indexPath.section)
        } else if elementKind.elementsEqual(UICollectionView.elementKindSectionFooter) {
            delegate?.listView(collectionView, didEndDisplayingFooterView: view,
                               section: aSection, at: indexPath.section)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
                        newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        let delegate: UICollectionViewDelegate? = delegate as? UICollectionViewDelegate

        // swiftlint:disable line_length
        if let transitionLayout: UICollectionViewTransitionLayout = delegate?.collectionView?(collectionView,
                                                                                              transitionLayoutForOldLayout: fromLayout,
                                                                                              newLayout: toLayout) {
            return transitionLayout
        } else {
            return UICollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
        }
        // swiftlint:enable line_length
    }

    override func indexTitles(for collectionView: UICollectionView) -> [String]? {
        dataSource?.sectionIndexTitles(collectionView)
    }
}

extension IQCollectionViewDiffableDataSource: UICollectionViewDelegateFlowLayout {

    // MARK: - Header Footer

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        let section: IQSection = snapshot().sectionIdentifiers[section]

        if let size: CGSize = section.headerSize {
            return size
        } else if let headerView: UIView = section.headerView {
            return headerView.frame.size
        } else if let header: String = section.header {
            let size: CGSize = IQCollectionViewHeaderFooter.sizeThatFitText(text: header,
                                                                            collectionView: collectionView)
            return size
        } else {
            return CGSize.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let delegate: UICollectionViewDelegateFlowLayout? = delegate as? UICollectionViewDelegateFlowLayout

        // swiftlint:disable line_length
        if let inset: UIEdgeInsets = delegate?.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAt: section) {
            return inset
        } else if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return collectionViewLayout.sectionInset
        } else {
            return .zero
        }
        // swiftlint:enable line_length
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let delegate: UICollectionViewDelegateFlowLayout? = delegate as? UICollectionViewDelegateFlowLayout

        // swiftlint:disable line_length
        if let spacing: CGFloat = delegate?.collectionView?(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section) {
            return spacing
        } else if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return collectionViewLayout.minimumLineSpacing
        } else {
            return 0
        }
        // swiftlint:enable line_length
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let delegate: UICollectionViewDelegateFlowLayout? = delegate as? UICollectionViewDelegateFlowLayout

        // swiftlint:disable line_length
        if let spacing: CGFloat = delegate?.collectionView?(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section) {
            return spacing
        } else if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return collectionViewLayout.minimumInteritemSpacing
        } else {
            return 0
        }
        // swiftlint:enable line_length
   }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let section = snapshot().sectionIdentifiers[section]

        if let size: CGSize = section.footerSize {
            return size
        } else if let headerView: UIView = section.footerView {
            return headerView.frame.size
        } else if let footer: String = section.footer {
            let size: CGSize = IQCollectionViewHeaderFooter.sizeThatFitText(text: footer,
                                                                            collectionView: collectionView)
            return size
        } else {
            return CGSize.zero
        }
    }

    // MARK: - Cell

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return .zero
        }

        if let size: CGSize = dataSource?.listView(collectionView, size: item, at: indexPath) {
            return size
        } else if let type: IQCellSizeProvider.Type = item.type as? IQCellSizeProvider.Type {
            return type.size(for: item.model, listView: collectionView)
        }

        return CGSize.zero
    }
}

extension IQCollectionViewDiffableDataSource: UICollectionViewDelegate {

    // MARK: - Selection

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {

        guard let cell: IQSelectableCell = collectionView.cellForItem(at: indexPath) as? IQSelectableCell else {
            return true
        }

        return cell.isHighlightable
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

        guard let cell: IQSelectableCell = collectionView.cellForItem(at: indexPath) as? IQSelectableCell else {
            return true
        }

        return cell.isSelectable
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

        guard let cell: IQSelectableCell = collectionView.cellForItem(at: indexPath) as? IQSelectableCell else {
            return true
        }

        return cell.isDeselectable
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(collectionView, didDeselect: item, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        canPerformPrimaryActionForItemAt indexPath: IndexPath) -> Bool {

        guard let cell: IQSelectableCell = collectionView.cellForItem(at: indexPath) as? IQSelectableCell else {
            return true
        }

        return cell.canPerformPrimaryAction
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
        delegate?.listView(collectionView, willDisplay: cell, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.listView(collectionView, didEndDisplaying: cell, at: indexPath)
    }

//    // MARK: - Context menu
//    func collectionView(_ collectionView: UICollectionView,
//                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
//                        point: CGPoint) -> UIContextMenuConfiguration? {
//
//    }

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

        // swiftlint:disable line_length
        guard let indexPath = contextMenuPreviewIndexPath,
              let cell: IQCellActionsProvider = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider else {
            return
        }
        // swiftlint:enable line_length

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

extension IQCollectionViewDiffableDataSource: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        var items: [IQItem] = []
        var itemIndexPaths: [IndexPath] = []

        indexPaths.forEach { indexPath in
            if let item: IQItem = itemIdentifier(for: indexPath) {
                items.append(item)
                itemIndexPaths.append(indexPath)
            }
        }

        dataSource?.listView(collectionView, prefetch: items, at: itemIndexPaths)
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        var items: [IQItem] = []
        var itemIndexPaths: [IndexPath] = []

        indexPaths.forEach { indexPath in
            if let item: IQItem = itemIdentifier(for: indexPath) {
                items.append(item)
                itemIndexPaths.append(indexPath)
            }
        }

        dataSource?.listView(collectionView, cancelPrefetch: items, at: itemIndexPaths)
    }
}

//    // Focus
//    @available(iOS 9.0, *)
//    optional func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool
//
//    @available(iOS 9.0, *)
//    optional func collectionView(_ collectionView: UICollectionView,
//      shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool
//
//    @available(iOS 9.0, *)
//    optional func collectionView(_ collectionView: UICollectionView,
//      didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
//
//    @available(iOS 9.0, *)
//    optional func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath?
//
//
//    /// Determines if the item at the specified index path should also become selected when focus moves to it.
//    /// If the collection view's global selectionFollowsFocus is enabled, this method will allow
//      you to override that behavior on a per-index path basis.
//      This method is not called if selectionFollowsFocus is disabled.
//    @available(iOS 15.0, *)
//    optional func collectionView(_ collectionView: UICollectionView,
//      selectionFollowsFocusForItemAt indexPath: IndexPath) -> Bool
//
//
//    @available(iOS 15.0, *)
//    optional func collectionView(_ collectionView: UICollectionView,
//      targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
//      atCurrentIndexPath currentIndexPath: IndexPath,
//      toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath
//
//    @available(iOS, introduced: 9.0, deprecated: 15.0)
//    optional func collectionView(_ collectionView: UICollectionView,
//      targetIndexPathForMoveFromItemAt currentIndexPath: IndexPath,
//      toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath
//
//      // customize the content offset to be applied during transition or update animations
//    @available(iOS 9.0, *)
//    optional func collectionView(_ collectionView: UICollectionView,
//      targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint
//
//
//    // Editing
//    /* Asks the delegate to verify that the given item is editable.
//     *
//     * @param collectionView The collection view object requesting this information.
//     * @param indexPath An index path locating an item in `collectionView`.
//     *
//     * @return `YES` if the item is editable; otherwise, `NO`. Defaults to `YES`.
//     */
//    @available(iOS 14.0, *)
//    optional func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool
//
//
//    // Spring Loading
//
//    /* Allows opting-out of spring loading for an particular item.
//     *
//     * If you want the interaction effect on a different subview of
//      the spring loaded cell, modify the context.targetView property.
//     * The default is the cell.
//     *
//     * If this method is not implemented, the default is YES.
//     */
//    @available(iOS 11.0, *)
//    optional func collectionView(_ collectionView: UICollectionView,
//      shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool
//
//
//    // Multiple Selection
//
//    /* Allows a two-finger pan gesture to automatically enable allowsMultipleSelection and
//      start selecting multiple cells.
//     *
//     * After a multi-select gesture is recognized, this method will be called
//      before allowsMultipleSelection is automatically
//     * set to YES to allow the user to select multiple contiguous items using
//      a two-finger pan gesture across the constrained
//     * scroll direction.
//     *
//     * If the collection view has no constrained scroll direction
//      (i.e., the collection view scrolls both horizontally and vertically),
//     * then this method will not be called and the multi-select gesture will be disabled.
//     *
//     * If this method is not implemented, the default is NO.
//     */
//    @available(iOS 13.0, *)
//    optional func collectionView(_ collectionView: UICollectionView,
//      shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool
//
//
//    /* Called right after allowsMultipleSelection is set to YES if
//      -collectionView:shouldBeginMultipleSelectionInteractionAtIndexPath:
//     * returned YES.
//     *
//     * In your app, this would be a good opportunity to update the state of
//      your UI to reflect the fact that the user is now selecting
//     * multiple items at once; such as updating buttons to say "Done" instead of "Select"/"Edit", for instance.
//     */
//    @available(iOS 13.0, *)
//    optional func collectionView(_ collectionView: UICollectionView,
//      didBeginMultipleSelectionInteractionAt indexPath: IndexPath)
//
//
//    /* Called when the multi-select interaction ends.
//     *
//     * At this point, the collection view will remain in multi-select mode,
//      but this delegate method is called to indicate that the
//     * multiple selection gesture or hardware keyboard interaction has ended.
//     */
//    @available(iOS 13.0, *)
//    optional func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView)
//
//    /**
//     * @abstract Return a valid @c UIWindowSceneActivationConfiguration to
//      allow for the cell to be expanded into a new scene.
//      Return nil to prevent the interaction from starting.
//     *
//     * @param collectionView The collection view
//     * @param indexPath The index path of the cell being interacted with
//     * @param point The centroid of the interaction in the collection view's coordinate space.
//     */
//    @available(iOS 15.0, *)
//    optional func collectionView(_ collectionView: UICollectionView,
//      sceneActivationConfigurationForItemAt indexPath: IndexPath,
//      point: CGPoint) -> UIWindowScene.ActivationConfiguration?
// }
