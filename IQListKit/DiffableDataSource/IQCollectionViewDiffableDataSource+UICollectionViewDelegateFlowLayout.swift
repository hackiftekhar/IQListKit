//
//  IQCollectionViewDiffableDataSource+UICollectionViewDelegateFlowLayout.swift
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
extension IQCollectionViewDiffableDataSource: UICollectionViewDelegateFlowLayout {

    // MARK: - Supplementary view

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return .zero
        }
        let aSection: IQSection = sectionIdentifiers[section]

        guard let type: IQViewSizeProvider.Type = aSection.headerType as? IQViewSizeProvider.Type,
              let headerModel = aSection.headerModel else {
            return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero
        }

        let sectionSize: CGSize
        if type == IQSupplementaryViewPlaceholder.self,
        let size = IQCollectionTitleSupplementaryView.size(for: headerModel, listView: collectionView) {
            sectionSize = size
        } else if let size = type.size(for: headerModel, listView: collectionView) {
            sectionSize = size
        } else if let cvfl = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width: CGFloat = collectionView.frame.width - cvfl.sectionInset.left - cvfl.sectionInset.right
            sectionSize = CGSize(width: width, height: 22)
        } else {
            sectionSize = .zero
        }

        return sectionSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let delegate: UICollectionViewDelegateFlowLayout? = delegate as? UICollectionViewDelegateFlowLayout

        if let inset: UIEdgeInsets = delegate?.collectionView?(collectionView,
                                                               layout: collectionViewLayout,
                                                               insetForSectionAt: section) {
            return inset
        } else if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return collectionViewLayout.sectionInset
        } else {
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let delegate: UICollectionViewDelegateFlowLayout? = delegate as? UICollectionViewDelegateFlowLayout

        if let spacing: CGFloat = delegate?.collectionView?(collectionView,
                                                            layout: collectionViewLayout,
                                                            minimumLineSpacingForSectionAt: section) {
            return spacing
        } else if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return collectionViewLayout.minimumLineSpacing
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let delegate: UICollectionViewDelegateFlowLayout? = delegate as? UICollectionViewDelegateFlowLayout

        if let spacing: CGFloat = delegate?.collectionView?(collectionView,
                                                            layout: collectionViewLayout,
                                                            minimumInteritemSpacingForSectionAt: section) {
            return spacing
        } else if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return collectionViewLayout.minimumInteritemSpacing
        } else {
            return 0
        }
   }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard section < sectionIdentifiers.count else {
            return .zero
        }
        let aSection: IQSection = sectionIdentifiers[section]

        guard let type: IQViewSizeProvider.Type = aSection.footerType as? IQViewSizeProvider.Type,
              let footerModel = aSection.footerModel else {
            return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero
        }

        let sectionSize: CGSize
        if type == IQSupplementaryViewPlaceholder.self,
        let size = IQCollectionTitleSupplementaryView.size(for: footerModel, listView: collectionView) {
            sectionSize = size
        } else if let size = type.size(for: footerModel, listView: collectionView) {
            sectionSize = size
        } else if let cvfl = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            sectionSize = CGSize(width: collectionView.frame.width - cvfl.sectionInset.left - cvfl.sectionInset.right,
                                 height: 22)
        } else {
            sectionSize = .zero
        }

        return sectionSize
    }

    // MARK: - Cell

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let item: IQItem = itemIdentifier(for: indexPath) else {
            return .zero
        }

        let itemSize: CGSize
        if let size: CGSize = dataSource?.listView(collectionView, size: item, at: indexPath) {
            itemSize = size
        } else if let type: IQViewSizeProvider.Type = item.type as? IQViewSizeProvider.Type,
                  let size = type.size(for: item.model, listView: collectionView) {
            itemSize = size
        } else if let cvfl = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width: CGFloat = collectionView.frame.width - cvfl.sectionInset.left - cvfl.sectionInset.right
            itemSize = CGSize(width: width, height: 0)
        } else {
            itemSize = .zero
        }

        return itemSize
    }
}
