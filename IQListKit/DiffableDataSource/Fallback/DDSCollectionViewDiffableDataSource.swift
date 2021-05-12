//
//  DDSCollectionViewDiffableDataSource.swift
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
import DiffableDataSources

// MARK: Improved DiffableDataSource of UICollectionView

@available(iOS, deprecated: 13.0)
internal class DDSCollectionViewDiffableDataSource: CollectionViewDiffableDataSource<IQSection, IQItem> {

    weak var delegate: IQListViewDelegate?
    weak var dataSource: IQListViewDataSource?

    private var contextMenuPreviewIndexPath: IndexPath?

    // MARK: - Header Footer
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {

        let aSection = snapshot().sectionIdentifiers[indexPath.section]

        if kind.elementsEqual(UICollectionView.elementKindSectionHeader) {
            let reusableView: UICollectionReusableView

            let headerView = dataSource?.listView(collectionView, headerFor: aSection, at: indexPath.section) ?? aSection.headerView

            if let headerView = headerView as? UICollectionReusableView {
                reusableView = headerView
            } else if let headerView = headerView {
                let sHeader = collectionView.dequeue(UICollectionReusableView.self, kind: kind, for: indexPath)
                sHeader.frame = headerView.bounds
                sHeader.addSubview(headerView)
                reusableView = sHeader
            } else if let header = aSection.header {
                let sHeader = collectionView.dequeue(IQCollectionViewHeaderFooter.self, kind: kind, for: indexPath)
                sHeader.textLabel.text = header
                reusableView = sHeader
            } else {
                reusableView = collectionView.dequeue(UICollectionReusableView.self, kind: kind, for: indexPath)
            }

            delegate?.listView(collectionView, modifyHeader: reusableView, section: aSection, at: indexPath.section)

            return reusableView
        } else if kind.elementsEqual(UICollectionView.elementKindSectionFooter) {
            let reusableView: UICollectionReusableView

            let footerView = dataSource?.listView(collectionView, footerFor: aSection, at: indexPath.section) ?? aSection.footerView

            if let footerView = footerView as? UICollectionReusableView {
                reusableView = footerView
            } else if let footerView = footerView {
                let sFooter = collectionView.dequeue(UICollectionReusableView.self, kind: kind, for: indexPath)
                sFooter.frame = footerView.bounds
                sFooter.addSubview(footerView)
                reusableView = sFooter
            } else if let footer = aSection.footer {
                let sFooter = collectionView.dequeue(IQCollectionViewHeaderFooter.self, kind: kind, for: indexPath)
                sFooter.textLabel.text = footer
                reusableView = sFooter
            } else {
                reusableView = collectionView.dequeue(UICollectionReusableView.self, kind: kind, for: indexPath)
            }

            delegate?.listView(collectionView, modifyHeader: reusableView, section: aSection, at: indexPath.section)

            return reusableView
        } else {
            return collectionView.dequeue(UICollectionReusableView.self, kind: kind, for: indexPath)
        }
    }
}

@available(iOS, deprecated: 13.0)
extension DDSCollectionViewDiffableDataSource: UICollectionViewDelegateFlowLayout {

    // MARK: - Header Footer

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        let aSection = snapshot().sectionIdentifiers[section]

        if let size = aSection.headerSize {
            return size
        } else if let headerView = aSection.headerView {
            return headerView.frame.size
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
        } else if let headerView = aSection.footerView {
            return headerView.frame.size
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

@available(iOS, deprecated: 13.0)
extension DDSCollectionViewDiffableDataSource: UICollectionViewDelegate {

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
        collectionView.deselectItem(at: indexPath, animated: true)

        if let item = itemIdentifier(for: indexPath) {
            delegate?.listView(collectionView, didSelect: item, at: indexPath)
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

    @available(iOS 13.0, *)
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

    @available(iOS 13.0, *)
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

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                        animator: UIContextMenuInteractionCommitAnimating) {
        if let indexPath = contextMenuPreviewIndexPath,
           let cell = collectionView.cellForItem(at: indexPath) as? IQCellActionsProvider {
            cell.performPreviewAction(configuration: configuration, animator: animator)
        }
    }

    @available(iOS 13.0, *)
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
