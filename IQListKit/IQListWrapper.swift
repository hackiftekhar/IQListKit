//
//  IQListWrapper.swift
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

import Foundation

final public class IQListWrapper<T: IQModelableCell> {

    public enum Section: Hashable {
        case main
    }

    public let list: IQList

    public init(listView: IQListView,
                type: T.Type, registerType: IQList.RegisterType,
                delegateDataSource: IQListViewDelegateDataSource? = nil,
                defaultRowAnimation: UITableView.RowAnimation = .fade,
                reloadQueue: DispatchQueue? = nil) {
        list = IQList(listView: listView, delegateDataSource: delegateDataSource,
                      defaultRowAnimation: defaultRowAnimation, reloadQueue: reloadQueue)
        list.registerCell(type: type.self, registerType: registerType)
    }

    private var _models: [T.Model] = []
    public var models: [T.Model] {
        get {
            return _models
        }
        set {
            _models = newValue
            self.reloadData(animated: false)
        }
    }

    public func setModels(_ models: [T.Model], animated: Bool) {
        _models = models
        self.reloadData(animated: animated)
    }

    private func reloadData(animated: Bool) {

        list.reloadData({
            let section = IQSection(identifier: Section.main)
            list.append([section])
            list.append(T.self, models: models)
        }, animatingDifferences: animated)
    }
}
