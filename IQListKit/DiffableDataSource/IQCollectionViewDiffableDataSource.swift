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

@MainActor
internal final class IQCollectionViewDiffableDataSource: UICollectionViewDiffableDataSource<IQSection, IQItem> {

    @MainActor internal var registeredSupplementaryViews: [String: [any IQModelableSupplementaryView.Type]] = [:]

    @MainActor internal var contextMenuPreviewIndexPath: IndexPath?

    @MainActor weak var proxyDelegate: IQListViewProxyDelegate?
    @MainActor weak var delegate: IQListViewDelegate?
    @MainActor weak var dataSource: IQListViewDataSource?
    @MainActor internal var clearsSelectionOnDidSelect: Bool = true

    override init(collectionView: UICollectionView,
                  cellProvider: @escaping IQCollectionViewDiffableDataSource.CellProvider) {
        super.init(collectionView: collectionView, cellProvider: cellProvider)
    }

    // MARK: - Supplementary view

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {

        guard let registeredTypes: [any IQModelableSupplementaryView.Type] = registeredSupplementaryViews[kind] else {
            fatalError("Please register a supplementary view first for '\(kind)' kind")
        }
        let identifier: String

        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard indexPath.section < sectionIdentifiers.count else {
            let view = collectionView.dequeue(UICollectionReusableView.self,
                                              kind: kind, for: indexPath)
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
                // If both types are same then it create a confusing condition, so ignoring if both are of same type
            } else if let headerType = aSection.headerType,
                      let footerType = aSection.footerType,
                      headerType == footerType,
                      registeredTypes.contains(where: { $0 == headerType}) {
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
                        Header and Footer both are of same type '\(headerType.self)'.
                        Please try registering different types for header and footer
                        """)
                }
            } else if let headerType = aSection.headerType,
                      registeredTypes.contains(where: { $0 == headerType}) {
                identifier = String(describing: headerType)
                model = aSection.headerModel
            } else if let footerType = aSection.footerType,
                      registeredTypes.contains(where: { $0 == footerType}) {
                identifier = String(describing: footerType)
                model = aSection.footerModel
            } else if let item: IQItem = itemIdentifier(for: indexPath),
                      !(item.supplementaryType is IQSupplementaryViewPlaceholder.Type) {
                identifier = String(describing: item.supplementaryType)
                model = item.supplementaryModel as? AnyHashable
            } else if let firstType = registeredTypes.first {
                identifier = String(describing: firstType)
                model = nil
            } else {
                identifier = ""
                model = nil
            }
        } else if let item: IQItem = itemIdentifier(for: indexPath),
                  !(item.supplementaryType is IQSupplementaryViewPlaceholder.Type) {
            identifier = String(describing: item.supplementaryType)
            model = item.supplementaryModel as? AnyHashable
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
                view.privateSetModel(model)
            } else {
                print("""
                    '\(kind)' with identifier '\(identifier)' \
                    does not confirm to the '\(IQModelModifiable.self)' protocol
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

        if let view: any IQModelableSupplementaryView = supplementaryView as? any IQModelableSupplementaryView {
            delegate?.listView(collectionView, modifySupplementaryElement: view,
                               section: aSection, kind: kind, at: indexPath)
        }

        return supplementaryView
    }
    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String, at indexPath: IndexPath) {

        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard indexPath.section < sectionIdentifiers.count else {
            return
        }
        let aSection: IQSection = sectionIdentifiers[indexPath.section]

        if let view: any IQModelableSupplementaryView = view as? any IQModelableSupplementaryView {
            delegate?.listView(collectionView, willDisplaySupplementaryElement: view,
                               section: aSection, kind: elementKind, at: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplayingSupplementaryView view: UICollectionReusableView,
                        forElementOfKind elementKind: String, at indexPath: IndexPath) {

        let sectionIdentifiers: [IQSection] = snapshot().sectionIdentifiers
        guard indexPath.section < sectionIdentifiers.count else {
            return
        }
        let aSection: IQSection = sectionIdentifiers[indexPath.section]

        if let view: any IQModelableSupplementaryView = view as? any IQModelableSupplementaryView {
            delegate?.listView(collectionView, didEndDisplayingSupplementaryElement: view,
                               section: aSection, kind: elementKind, at: indexPath)
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

//    override func collectionView(_ collectionView: UICollectionView,
//                                 indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
//
//    }
}
