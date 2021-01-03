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

// MARK: IQListViewDelegate

public protocol IQListViewDelegate: UIScrollViewDelegate {

    //Will give a chance to modify or other configuration of cell if necessary
    func listView(_ listView: IQListView, modifyCell cell: IQListCell, at indexPath: IndexPath)

    //Cell will about to display
    func listView(_ listView: IQListView, willDisplay cell: IQListCell, at indexPath: IndexPath)

    //Cell did end displaying
    func listView(_ listView: IQListView, didEndDisplaying cell: IQListCell, at indexPath: IndexPath)

    //An item is selected
    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath)
}

// MARK: IQListViewDataSource

public protocol IQListViewDataSource: class {

    //Return the size of an Item, for tableView the size.height will only be effective
    func listView(_ listView: IQListView, size item: IQItem, at indexPath: IndexPath) -> CGSize?

    //Return the headerView of section
    func listView(_ listView: IQListView, headerFor section: IQSection, at sectionIndex: Int) -> UIView?

    //Return the footerView of section
    func listView(_ listView: IQListView, footerFor section: IQSection, at sectionIndex: Int) -> UIView?
}

// MARK: Combined delegate/datasource
public typealias IQListViewDelegateDataSource = (IQListViewDelegate & IQListViewDataSource)

// MARK: Default implementations of protocols

public extension IQListViewDelegate {

    func listView(_ listView: IQListView, modifyCell cell: IQListCell, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, willDisplay cell: IQListCell, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, didEndDisplaying cell: IQListCell, at indexPath: IndexPath) {}

    func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {}
}

public extension IQListViewDataSource {

    func listView(_ listView: IQListView, size item: IQItem, at indexPath: IndexPath) -> CGSize? { return nil }

    func listView(_ listView: IQListView, headerFor section: IQSection, at sectionIndex: Int) -> UIView? { return nil }

    func listView(_ listView: IQListView, footerFor section: IQSection, at sectionIndex: Int) -> UIView? { return nil }
}
