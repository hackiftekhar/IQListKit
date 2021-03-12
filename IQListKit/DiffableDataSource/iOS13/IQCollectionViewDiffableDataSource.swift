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

@available(iOS 13.0, *)
internal final class IQCollectionViewDiffableDataSource: UICollectionViewDiffableDataSource<IQSection, IQItem> {

    weak var delegate: IQListViewDelegate?
    weak var dataSource: IQListViewDataSource?
    var clearsSelectionOnDidSelect = true

    private var contextMenuPreviewIndexPath: IndexPath?

    // MARK: - Header Footer

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {

        let aSection = snapshot().sectionIdentifiers[indexPath.section]

        if kind.elementsEqual(UICollectionView.elementKindSectionHeader) {

            if let headerView = dataSource?.listView(collectionView, headerFor: aSection, at: indexPath.section)
                as? UICollectionReusableView {
                return headerView
            } else if let header = aSection.header {
                let sHeader = collectionView.dequeue(IQCollectionViewHeaderFooter.self, kind: kind, for: indexPath)
                sHeader.textLabel.text = header
                return sHeader
            }

        } else if kind.elementsEqual(UICollectionView.elementKindSectionFooter) {

            if let headerView = dataSource?.listView(collectionView, footerFor: aSection, at: indexPath.section)
                as? UICollectionReusableView {
                return headerView
            } else if let footer = aSection.footer {
                let sFooter = collectionView.dequeue(IQCollectionViewHeaderFooter.self, kind: kind, for: indexPath)
                sFooter.textLabel.text = footer
                return sFooter
            }
        }

        return collectionView.dequeue(UICollectionReusableView.self, kind: kind, for: indexPath)
    }

    override func indexTitles(for collectionView: UICollectionView) -> [String]? {
        dataSource?.sectionIndexTitles(collectionView)
    }
}

@available(iOS 13.0, *)
extension IQCollectionViewDiffableDataSource: UICollectionViewDelegateFlowLayout {

    // MARK: - Header Footer

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        let aSection = snapshot().sectionIdentifiers[section]

        if let size = aSection.headerSize {
            return size
        } else {
            let size = IQCollectionViewHeaderFooter.sizeThatFitText(text: aSection.header,
                                                                    collectionView: collectionView)
            return size
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let aSection = snapshot().sectionIdentifiers[section]

        if let size = aSection.footerSize {
            return size
        } else {
            let size = IQCollectionViewHeaderFooter.sizeThatFitText(text: aSection.footer,
                                                                    collectionView: collectionView)
            return size
        }
    }

    // MARK: - Cell

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let item = itemIdentifier(for: indexPath) {
            if let size = dataSource?.listView(collectionView, size: item, at: indexPath) {
                return size
            } else if let type = item.type as? IQCellSizeProvider.Type {
                return type.size(for: item.model, listView: collectionView)
            }
        }

        return CGSize(width: 0, height: 0)
    }
}

@available(iOS 13.0, *)
extension IQCollectionViewDiffableDataSource: UICollectionViewDelegate {

    // MARK: - Selection

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {

        if let cell = collectionView.cellForItem(at: indexPath) as? IQSelectableCell {
            return cell.isHighlightable
        }

        return true
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {

        if let cell = collectionView.cellForItem(at: indexPath) as? IQSelectableCell {
            return cell.isSelectable
        }

        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if clearsSelectionOnDidSelect {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        if let item = itemIdentifier(for: indexPath) {
            delegate?.listView(collectionView, didSelect: item, at: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        if let item = itemIdentifier(for: indexPath) {
            delegate?.listView(collectionView, didDeselect: item, at: indexPath)
        }
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
        if let cell = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider,
           let configuration = cell.contextMenuConfiguration() {
            contextMenuPreviewIndexPath = indexPath
            return configuration
        }

        return nil
    }

    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration
                            configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        if let indexPath = contextMenuPreviewIndexPath,
           let cell = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider,
           let view = cell.contextMenuPreviewView(configuration: configuration) {
            return UITargetedPreview(view: view)
        }
        return nil
    }

    func collectionView(_ collectionView: UICollectionView,
                        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                        animator: UIContextMenuInteractionCommitAnimating) {
        if let indexPath = contextMenuPreviewIndexPath,
           let cell = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider {
            cell.performPreviewAction(configuration: configuration, animator: animator)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        previewForDismissingContextMenuWithConfiguration
                            configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        if let indexPath = contextMenuPreviewIndexPath,
           let cell = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider,
           let view = cell.contextMenuPreviewView(configuration: configuration) {
            return UITargetedPreview(view: view)
        }
        return nil
    }
}
