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
internal final class DDSCollectionViewDiffableDataSource: CollectionViewDiffableDataSource<IQSection, IQItem> {

    private var contextMenuPreviewIndexPath: IndexPath?
    private let _collectionViewDiffableDataSource: IQCommonCollectionViewDiffableDataSource =
        IQCommonCollectionViewDiffableDataSource()

    weak var delegate: IQListViewDelegate? {
        get {   _collectionViewDiffableDataSource.delegate   }
        set {   _collectionViewDiffableDataSource.delegate = newValue    }
    }

    weak var dataSource: IQListViewDataSource? {
        get {   _collectionViewDiffableDataSource.dataSource }
        set {   _collectionViewDiffableDataSource.dataSource = newValue  }
    }

    var clearsSelectionOnDidSelect: Bool {
        get {   _collectionViewDiffableDataSource.clearsSelectionOnDidSelect }
        set {   _collectionViewDiffableDataSource.clearsSelectionOnDidSelect = newValue  }
    }

    // MARK: - Header Footer

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {

        let aSection = snapshot().sectionIdentifiers[indexPath.section]
        return _collectionViewDiffableDataSource.collectionView(collectionView,
                                                                viewForSupplementaryElementOfKind: kind,
                                                                at: indexPath,
                                                                section: aSection)
    }

    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        _collectionViewDiffableDataSource.indexTitles(for: collectionView)
    }
}

@available(iOS, deprecated: 13.0)
extension DDSCollectionViewDiffableDataSource: UICollectionViewDelegateFlowLayout {

    // MARK: - Header Footer

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        let aSection = snapshot().sectionIdentifiers[section]
        return _collectionViewDiffableDataSource.collectionView(collectionView,
                                                                layout: collectionViewLayout,
                                                                referenceSizeForHeaderInSection: aSection)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let aSection = snapshot().sectionIdentifiers[section]
        return _collectionViewDiffableDataSource.collectionView(collectionView,
                                                                layout: collectionViewLayout,
                                                                referenceSizeForFooterInSection: aSection)
    }

    // MARK: - Cell

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let item: IQItem? = itemIdentifier(for: indexPath)
        return _collectionViewDiffableDataSource.collectionView(collectionView,
                                                                layout: collectionViewLayout,
                                                                sizeForItemAt: indexPath,
                                                                item: item)
    }
}

@available(iOS, deprecated: 13.0)
extension DDSCollectionViewDiffableDataSource: UICollectionViewDelegate {

    // MARK: - Selection

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        _collectionViewDiffableDataSource.collectionView(collectionView, shouldHighlightItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        _collectionViewDiffableDataSource.collectionView(collectionView, shouldSelectItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item: IQItem? = itemIdentifier(for: indexPath)
        _collectionViewDiffableDataSource.collectionView(collectionView, didSelectItemAt: indexPath, item: item)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let item: IQItem? = itemIdentifier(for: indexPath)
        _collectionViewDiffableDataSource.collectionView(collectionView, didDeselectItemAt: indexPath, item: item)
    }

    // MARK: - Cell
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        _collectionViewDiffableDataSource.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        _collectionViewDiffableDataSource.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
    }

    // MARK: - Context menu

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        _collectionViewDiffableDataSource
            .collectionView(collectionView,
                            contextMenuConfigurationForItemAt: indexPath,
                            point: point)
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration
                            configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        _collectionViewDiffableDataSource
            .collectionView(collectionView,
                            previewForHighlightingContextMenuWithConfiguration: configuration)
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                        animator: UIContextMenuInteractionCommitAnimating) {
        _collectionViewDiffableDataSource
            .collectionView(collectionView,
                            willPerformPreviewActionForMenuWith: configuration,
                            animator: animator)
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        previewForDismissingContextMenuWithConfiguration
                            configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        _collectionViewDiffableDataSource
            .collectionView(collectionView,
                            previewForDismissingContextMenuWithConfiguration: configuration)
    }
}
