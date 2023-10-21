//
//  IQCollectionViewSectionLayout.swift
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
public final class IQCollectionViewSectionLayout {

    public class func sectionLayout(direction: UICollectionView.ScrollDirection,
                                    itemSize: NSCollectionLayoutSize,
                                    supplementaryItems: [NSCollectionLayoutSupplementaryItem] = [],
                                    itemContentInsets: NSDirectionalEdgeInsets? = nil,
                                    groupSize: NSCollectionLayoutSize,
                                    gridCount: Int? = nil,
                                    interItemSpacing: NSCollectionLayoutSpacing? = nil) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: supplementaryItems)
        if let itemContentInsets = itemContentInsets {
            item.contentInsets = itemContentInsets
        }

        let group: NSCollectionLayoutGroup
        switch direction {
        case .horizontal:
            if let gridCount = gridCount {
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitem: item,
                                                           count: gridCount)
            } else {
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitems: [item])
            }
        case .vertical:
            if let gridCount = gridCount {
                group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         subitem: item,
                                                         count: gridCount)
            } else {
                group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         subitems: [item])
            }
        @unknown default:
            fatalError("Unsupported direction")
        }

        if let interItemSpacing = interItemSpacing {
            group.interItemSpacing = interItemSpacing
        }

        let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group)

        return section
    }

    @available(iOS 14.0, *)
    public class func listSectionLayout(appearance: UICollectionLayoutListConfiguration.Appearance,
                                        layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection.list(using: .init(appearance: appearance),
                                                     layoutEnvironment: layoutEnvironment)

        return section
    }
}
