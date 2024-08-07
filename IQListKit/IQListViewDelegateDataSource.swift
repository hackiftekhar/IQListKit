//
//  IQListViewDelegateDataSource.swift
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

// MARK: - IQListViewDelegate

@objc public protocol IQListViewProxyDelegate: AnyObject {
    @MainActor
    @objc optional func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView)
}

@MainActor
public protocol IQListViewDelegate: UIScrollViewDelegate, Sendable {

    /// Will give a chance to modify or other configuration of cell if necessary
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - cell: The IQModelableCell which can be typecast to your cell.
    ///   - indexPath: indexPath in which the cell will display
    func listView(_ listView: IQListView, modifyCell cell: some IQModelableCell, at indexPath: IndexPath)

    /// Cell will about to display
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - cell: The IQModelableCell which is about to display in the listView
    ///   - indexPath: indexPath in which the cell is about to display
    func listView(_ listView: IQListView, willDisplay cell: some IQModelableCell, at indexPath: IndexPath)

    /// Cell did end displaying
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - cell: The IQModelableCell which is about to be removed from UI
    ///   - indexPath: indexPath in which the cell is about the disappear
    func listView(_ listView: IQListView, didEndDisplaying cell: some IQModelableCell, at indexPath: IndexPath)

    /// An item is selected
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - item: the item which is selected. item.type will be the cell type. item.model will be the Model
    ///   - indexPath: indexPath which is selected
    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath)

    /// An item is deselected
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - item: the item which is deselected. item.type will be the cell type. item.model will be the Model
    ///   - indexPath: indexPath which is deselected
    func listView(_ listView: IQListView, didDeselect item: IQItem, at indexPath: IndexPath)

    /// An item is highlighted
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - item: the item which is highlighted
    ///   - indexPath: indexPath which is highlighted
    func listView(_ listView: IQListView, didHighlight item: IQItem, at indexPath: IndexPath)

    /// An item is unhighlighted
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - item: the item which is unhighlighted.
    ///   - indexPath: indexPath which is unhighlighted
    func listView(_ listView: IQListView, didUnhighlight item: IQItem, at indexPath: IndexPath)

    /// An item is selected
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - item: the item which is performing the action. item.type will be the cell type. item.model will be the Model
    ///   - indexPath: indexPath which is performing the action
    func listView(_ listView: IQListView, performPrimaryAction item: IQItem, at indexPath: IndexPath)

    /// Will give a chance to modify the supplementary view before appearance
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - view: supplementary  view which will be shown
    ///   - section: section of the ListView
    ///   - kind: Kind of section. Either header or footer or customized
    ///   - indexPath: contains section of the ListView
    func listView(_ listView: IQListView, modifySupplementaryElement view: some IQModelableSupplementaryView,
                  section: IQSection, kind: String, at indexPath: IndexPath)

    /// Supplementary view will about to display
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - view: supplementary View
    ///   - section: section of the ListView
    ///   - kind: Kind of section. Either header or footer or customized
    ///   - indexPath: section of the ListView
    func listView(_ listView: IQListView, willDisplaySupplementaryElement view: some IQModelableSupplementaryView,
                  section: IQSection, kind: String, at indexPath: IndexPath)

    /// Supplementary view did end displaying
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - view: supplementary View
    ///   - section: section of the ListView
    ///   - kind: Kind of section. Either header or footer or customized
    ///   - indexPath: section of the ListView
    func listView(_ listView: IQListView, didEndDisplayingSupplementaryElement view: some IQModelableSupplementaryView,
                  section: IQSection, kind: String, at indexPath: IndexPath)

    /// Cell will display context menu
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - configuration: UIContextMenuConfiguration
    ///   - animator: UIContextMenuInteractionAnimating
    ///   - item: IQItem
    ///   - indexPath: indexPath in which the cell is displaying
    func listView(_ listView: IQListView, willDisplayContextMenu configuration: UIContextMenuConfiguration,
                  animator: UIContextMenuInteractionAnimating?, item: IQItem, at indexPath: IndexPath)

    /// Cell will end display context menu
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - configuration: UIContextMenuConfiguration
    ///   - animator: UIContextMenuInteractionAnimating
    ///   - item: IQItem
    ///   - indexPath: indexPath in which the cell is displaying
    func listView(_ listView: IQListView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
                  animator: UIContextMenuInteractionAnimating?, item: IQItem, at indexPath: IndexPath)

    @available(*, deprecated, message: "This function is renamed. You must adopt new function.",
                renamed: "listView(_:modifySupplementaryElement:section:kind:at:)")
    func listView(_ listView: IQListView, modifyHeader headerView: UIView, section: IQSection, at sectionIndex: Int)

    @available(*, deprecated, message: "This function is renamed. You must adopt new function.",
                renamed: "listView(_:modifySupplementaryElement:section:kind:at:)")
    func listView(_ listView: IQListView, modifyFooter footerView: UIView, section: IQSection, at sectionIndex: Int)

    @available(*, deprecated, message: "This function is renamed. You must adopt new function.",
                renamed: "listView(_:willDisplaySupplementaryElement:section:kind:at:)")
    func listView(_ listView: IQListView, willDisplayHeaderView view: UIView, section: IQSection, at sectionIndex: Int)

    @available(*, deprecated, message: "This function is renamed. You must adopt new function.",
                renamed: "listView(_:didEndDisplayingSupplementaryElement:section:kind:at:)")
    func listView(_ listView: IQListView, didEndDisplayingHeaderView view: UIView,
                  section: IQSection, at sectionIndex: Int)

    @available(*, deprecated, message: "This function is renamed. You must adopt new function.",
                renamed: "listView(_:willDisplaySupplementaryElement:section:kind:at:)")
    func listView(_ listView: IQListView, willDisplayFooterView view: UIView,
                  section: IQSection, at sectionIndex: Int)

    @available(*, deprecated, message: "This function is renamed. You must adopt new function.",
                renamed: "listView(_:didEndDisplayingSupplementaryElement:section:kind:at:)")
    func listView(_ listView: IQListView, didEndDisplayingFooterView view: UIView,
                  section: IQSection, at sectionIndex: Int)
}

// MARK: - IQListViewDataSource

@MainActor
public protocol IQListViewDataSource: AnyObject, Sendable {

    /// Return the size of an Item, for tableView the size.height will only be effective
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - item: the item which is asked for it's size. item.type will be the cell type. item.model will be the Model
    ///   - indexPath: indexPath of the item
    func listView(_ listView: IQListView, size item: IQItem, at indexPath: IndexPath) -> CGSize?

    /// Return the supplementary view  of section
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - section: section of the ListView
    ///   - kind: section of the ListView. UICollectionView.elementKindSectionHeader
    ///             or UICollectionView.elementKindSectionFooter or something custom type
    ///   - indexPath: section of the ListView
    func listView(_ listView: IQListView, supplementaryElementFor section: IQSection,
                  kind: String, at indexPath: IndexPath) -> (any IQModelableSupplementaryView)?

    /// Return the sectionIndexTitles for tableView
    /// - Parameter listView: The IQListView object
    func sectionIndexTitles(_ listView: IQListView) -> [String]?

    /// Will give a chance to prefetch items before appearance
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - items: items to prefetch data asynchronously
    ///   - indexPaths: indexPaths of the ListView
    func listView(_ listView: IQListView, prefetch items: [IQItem], at indexPaths: [IndexPath])

    /// Cancel prefetch items if not finished
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - items: items to cancel prefetch data
    ///   - indexPaths: indexPaths of the ListView
    func listView(_ listView: IQListView, cancelPrefetch items: [IQItem], at indexPaths: [IndexPath])

    /// Return true if we are allowed to move the item
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - item: the item which is asked for it can move.
    ///   - indexPath: indexPath of the item
    func listView(_ listView: IQListView, canMove item: IQItem, at indexPath: IndexPath) -> Bool?

    /// Your responsibility is to move source item to it's new destination
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - item: the item which is asked for it can move.
    ///   - indexPath: indexPath of the item
    func listView(_ listView: IQListView, move sourceItem: IQItem,
                  at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)

    /// Return true if we are allowed to edit the item
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - item: the item which is asked for it can move.
    ///   - indexPath: indexPath of the item
    func listView(_ listView: IQListView, canEdit item: IQItem, at indexPath: IndexPath) -> Bool?

    /// Take editing action
    /// - Parameters:
    ///   - listView: The IQListView object
    ///   - item: the item which is asked for it can move.
    ///   - indexPath: indexPath of the item
    func listView(_ listView: IQListView, commit item: IQItem,
                  style: UITableViewCell.EditingStyle, at indexPath: IndexPath)

    @available(*, deprecated, message: "This function is renamed. You must adopt new function.",
                renamed: "listView(_:supplementaryElementFor:kind:at:)")
    func listView(_ listView: IQListView, headerFor section: IQSection, at sectionIndex: Int) -> UIView?

    @available(*, deprecated, message: "This function is renamed. You must adopt new function.",
                renamed: "listView(_:supplementaryElementFor:kind:at:)")
    func listView(_ listView: IQListView, footerFor section: IQSection, at sectionIndex: Int) -> UIView?
}

// MARK: - Combined delegate/datasource
public typealias IQListViewDelegateDataSource = (IQListViewDelegate & IQListViewDataSource)

// MARK: - Default implementations of protocols

@MainActor
public extension IQListViewDelegate {

    func listView(_ listView: IQListView, modifyCell cell: some IQModelableCell, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, willDisplay cell: some IQModelableCell, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, didEndDisplaying cell: some IQModelableCell, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, performPrimaryAction item: IQItem, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, didDeselect item: IQItem, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, didHighlight item: IQItem, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, didUnhighlight item: IQItem, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, modifySupplementaryElement view: some IQModelableSupplementaryView,
                  section: IQSection, kind: String, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, willDisplaySupplementaryElement view: some IQModelableSupplementaryView,
                  section: IQSection, kind: String, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, didEndDisplayingSupplementaryElement view: some IQModelableSupplementaryView,
                  section: IQSection, kind: String, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, willDisplayContextMenu configuration: UIContextMenuConfiguration,
                  animator: UIContextMenuInteractionAnimating?, item: IQItem, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
                  animator: UIContextMenuInteractionAnimating?, item: IQItem, at indexPath: IndexPath) {}
}

// Deprecated functions
public extension IQListViewDelegate {
    func listView(_ listView: IQListView, modifyHeader headerView: UIView, section: IQSection, at sectionIndex: Int) {}
    func listView(_ listView: IQListView, modifyFooter footerView: UIView, section: IQSection, at sectionIndex: Int) {}
    func listView(_ listView: IQListView, willDisplayHeaderView view: UIView,
                  section: IQSection, at sectionIndex: Int) {}
    func listView(_ listView: IQListView, didEndDisplayingHeaderView view: UIView,
                  section: IQSection, at sectionIndex: Int) {}
    func listView(_ listView: IQListView, willDisplayFooterView view: UIView,
                  section: IQSection, at sectionIndex: Int) {}
    func listView(_ listView: IQListView, didEndDisplayingFooterView view: UIView,
                  section: IQSection, at sectionIndex: Int) {}
}

@MainActor
public extension IQListViewDataSource {

    func listView(_ listView: IQListView, size item: IQItem, at indexPath: IndexPath) -> CGSize? { return nil }

    func listView(_ listView: IQListView, supplementaryElementFor section: IQSection,
                  kind: String, at indexPath: IndexPath) -> (any IQModelableSupplementaryView)? { return nil }

    func sectionIndexTitles(_ listView: IQListView) -> [String]? { return nil }

    func listView(_ listView: IQListView, prefetch items: [IQItem], at indexPaths: [IndexPath]) {}

    func listView(_ listView: IQListView, cancelPrefetch items: [IQItem], at indexPaths: [IndexPath]) {}

    func listView(_ listView: IQListView, canEdit item: IQItem, at indexPath: IndexPath) -> Bool? { return nil }

    func listView(_ listView: IQListView, commit item: IQItem,
                  style: UITableViewCell.EditingStyle, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, canMove item: IQItem, at indexPath: IndexPath) -> Bool? { return nil }

    func listView(_ listView: IQListView, move sourceItem: IQItem,
                  at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {}
}

// Deprecated functions
public extension IQListViewDataSource {
    func listView(_ listView: IQListView, headerFor section: IQSection, at sectionIndex: Int) -> UIView? { return nil }
    func listView(_ listView: IQListView, footerFor section: IQSection, at sectionIndex: Int) -> UIView? { return nil }
}
