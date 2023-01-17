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

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.listView(collectionView, didDeselect: item, at: indexPath)
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
                        previewForHighlightingContextMenuWithConfiguration
                            configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard let indexPath: IndexPath = contextMenuPreviewIndexPath,
              let cell: IQCellActionsProvider = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider,
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
