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

    internal var registeredCells: [IQListCell.Type] = []
    internal var registeredSupplementaryViews: [String: [IQListSupplementaryView.Type]] = [:]

    private var contextMenuPreviewIndexPath: IndexPath?

    weak var proxyDelegate: IQListViewProxyDelegate?
    weak var delegate: IQListViewDelegate?
    weak var dataSource: IQListViewDataSource?
    var clearsSelectionOnDidSelect: Bool = true

    override init(collectionView: UICollectionView,
                  cellProvider: @escaping IQCollectionViewDiffableDataSource.CellProvider) {
        super.init(collectionView: collectionView, cellProvider: cellProvider)
    }

    // MARK: - Supplementary view

    // swiftlint:disable function_body_length
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {

        guard let supplementaryTypes: [IQListSupplementaryView.Type] = registeredSupplementaryViews[kind] else {
            fatalError("Please register a supplementary view first for '\(kind)' kind")
        }
        let identifier: String

        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard indexPath.section < sectionIdentifiers.count else {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: "UICollectionReusableView",
                                                                       for: indexPath)
            return view
        }
        let aSection: IQSection = sectionIdentifiers[indexPath.section]

        let model: AnyHashable?
       // It might be header or footer or may be for the 1st row
        if indexPath.row == 0 {

            if kind == UICollectionView.elementKindSectionHeader,
               let headerType = aSection.headerType {

                if headerType == IQSupplementaryViewPlaceholder.self,
                    let headerModel = aSection.headerModel as? IQCollectionTitleSupplementaryView.Model {
                    identifier = String(describing: IQCollectionTitleSupplementaryView.self)
                    model = headerModel
                } else {
                    identifier = String(describing: headerType)
                    model = aSection.headerModel
                }
            } else if kind == UICollectionView.elementKindSectionFooter,
                      let footerType = aSection.footerType {

                if footerType == IQSupplementaryViewPlaceholder.self,
                    let footerModel = aSection.footerModel as? IQCollectionTitleSupplementaryView.Model {
                    identifier = String(describing: IQCollectionTitleSupplementaryView.self)
                    model = footerModel
                } else {
                    identifier = String(describing: footerType)
                    model = aSection.footerModel
                }
            } else if let headerType = aSection.headerType, // If both types are same then it create a confusing condition, so ignoring if both are of same type
               let footerType = aSection.footerType,
               headerType == footerType,
               supplementaryTypes.contains(where: { $0 == headerType}) {
                if kind == UICollectionView.elementKindSectionHeader {
                    model = aSection.headerModel
                    identifier = String(describing: headerType)
                } else if kind == UICollectionView.elementKindSectionFooter {
                    model = aSection.footerModel
                    identifier = String(describing: footerType)
                } else {
                    identifier = ""
                    model = nil
                    print("""
                        Header and Footer both are of same type \(headerType.self).
                        Please try registering different types for header and footer
                        """)
                }
            } else if let headerType = aSection.headerType,
                      supplementaryTypes.contains(where: { $0 == headerType}) {
                identifier = String(describing: headerType)
                model = aSection.headerModel
            } else if let footerType = aSection.footerType,
                      supplementaryTypes.contains(where: { $0 == footerType}) {
                identifier = String(describing: footerType)
                model = aSection.footerModel
            } else if let item: IQItem = itemIdentifier(for: indexPath),
                      !(item.supplementaryType is IQSupplementaryViewPlaceholder.Type) {
                identifier = String(describing: item.supplementaryType)
                model = item.supplementaryModel
            } else if let firstType = supplementaryTypes.first {
                identifier = String(describing: firstType)
                model = nil
            } else {
                identifier = ""
                model = nil
            }
        } else if let item: IQItem = itemIdentifier(for: indexPath),
                  !(item.supplementaryType is IQSupplementaryViewPlaceholder.Type) {
            identifier = String(describing: item.supplementaryType)
            model = item.supplementaryModel
        } else {
            identifier = ""
            model = nil
        }

        let supplementaryView: UICollectionReusableView
        if let model = model {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: identifier,
                                                                       for: indexPath)
            if let view = view as? IQModelModifiable {
                view.setModel(model)
            } else {
                print("""
                    \(kind) with identifier \(identifier) \
                    does not confirm to the \(IQModelModifiable.self) protocol
                    """)
            }
            supplementaryView = view
        } else if let view = dataSource?.listView(collectionView,
                                                  supplementaryElementFor: aSection,
                                                  kind: kind, at: indexPath) {
            if let view = view as? UICollectionReusableView {
                supplementaryView = view
            } else {
                supplementaryView = collectionView.dequeue(UICollectionReusableView.self,
                                                           kind: kind, for: indexPath)
            }
        } else {
            supplementaryView = collectionView.dequeue(UICollectionReusableView.self,
                                                       kind: kind, for: indexPath)
        }

        delegate?.listView(collectionView, modifySupplementaryElement: supplementaryView,
                           section: aSection, kind: kind, at: indexPath)

        return supplementaryView
    }
    // swiftlint:enable function_body_length

    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String, at indexPath: IndexPath) {

        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard indexPath.section < sectionIdentifiers.count else {
            return
        }
        let aSection: IQSection = sectionIdentifiers[indexPath.section]

        delegate?.listView(collectionView, willDisplaySupplementaryElement: view,
                           section: aSection, kind: elementKind, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplayingSupplementaryView view: UICollectionReusableView,
                        forElementOfKind elementKind: String, at indexPath: IndexPath) {

        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard indexPath.section < sectionIdentifiers.count else {
            return
        }
        let aSection: IQSection = sectionIdentifiers[indexPath.section]

        delegate?.listView(collectionView, didEndDisplayingSupplementaryElement: view,
                           section: aSection, kind: elementKind, at: indexPath)
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

//    override func collectionView(_ collectionView: UICollectionView,
//                                 indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
//
//    }
}

extension IQCollectionViewDiffableDataSource: UICollectionViewDelegateFlowLayout {

    // MARK: - Supplementary view

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return .zero
        }
        let aSection: IQSection = sectionIdentifiers[section]

        guard let type: IQViewSizeProvider.Type = aSection.headerType as? IQViewSizeProvider.Type else {
            return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero
        }

        if type == IQSupplementaryViewPlaceholder.self {
            return IQCollectionTitleSupplementaryView.size(for: aSection.headerModel, listView: collectionView)
        } else {
            return type.size(for: aSection.headerModel, listView: collectionView)
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
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return .zero
        }
        let aSection: IQSection = sectionIdentifiers[section]

        guard let type: IQViewSizeProvider.Type = aSection.footerType as? IQViewSizeProvider.Type else {
            return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero
        }

        if type == IQSupplementaryViewPlaceholder.self {
            return IQCollectionTitleSupplementaryView.size(for: aSection.footerModel, listView: collectionView)
        } else {
            return type.size(for: aSection.footerModel, listView: collectionView)
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
        } else if let type: IQViewSizeProvider.Type = item.type as? IQViewSizeProvider.Type {
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
