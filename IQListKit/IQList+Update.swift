//
//  IQList+UpdateItem.swift
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

// MARK: - Update the list
/// Note that all these methods can also be used in a background threads since they all
/// methods deal with the models, not any UI elements.
/// NSDiffableDataSourceSnapshot.apply is also background thread safe
public extension IQList {

    @available(iOS 14.0, *)
    var reorderingHandlers: UICollectionViewDiffableDataSource<IQSection, IQItem>.ReorderingHandlers? {
        get {
            (diffableDataSource as? IQCollectionViewDiffableDataSource)?.reorderingHandlers
        }
        set {
            if let newValue = newValue {
                (diffableDataSource as? IQCollectionViewDiffableDataSource)?.reorderingHandlers = newValue
            }
        }
    }

    /// Performs the list reload
    /// - Parameters:
    ///   - updates: update block which will be called to generate the snapshot
    ///   - animatingDifferences: If true then animates the differences otherwise do not animate.
    ///   - completion: the completion block will be called after reloading the list
    func reloadData(_ updates: () -> Void,
                    updateExistingSnapshot: Bool = false,
                    animatingDifferences: Bool = true, diffing: Bool? = nil,
                    animation: UITableView.RowAnimation? = nil,
                    endLoadingOnCompletion: Bool = true,
                    completion: (() -> Void)? = nil) {

        if updateExistingSnapshot {
            batchSnapshot = snapshot()
        } else {
            batchSnapshot = IQDiffableDataSourceSnapshot()
        }

        updates()
        apply(batchSnapshot, animatingDifferences: animatingDifferences, diffing: diffing, animation: animation,
              endLoadingOnCompletion: endLoadingOnCompletion, completion: completion)
    }

    func apply(_ snapshot: IQDiffableDataSourceSnapshot,
               animatingDifferences: Bool = true, diffing: Bool? = nil,
               animation: UITableView.RowAnimation? = nil,
               endLoadingOnCompletion: Bool = true,
               completion: (() -> Void)? = nil) {

        if let reloadQueue = reloadQueue {
            reloadQueue.async { [weak self] in
                self?.privateApply(snapshot, animatingDifferences: animatingDifferences, diffing: diffing,
                                   animation: animation, endLoadingOnCompletion: endLoadingOnCompletion,
                                   completion: completion)
            }
        } else {
            privateApply(snapshot, animatingDifferences: animatingDifferences, diffing: diffing,
                         animation: animation, endLoadingOnCompletion: endLoadingOnCompletion,
                         completion: completion)
        }
    }

    private func privateApply(_ snapshot: IQDiffableDataSourceSnapshot,
                              animatingDifferences: Bool = true, diffing: Bool? = nil,
                              animation: UITableView.RowAnimation? = nil,
                              endLoadingOnCompletion: Bool = true,
                              completion: (() -> Void)? = nil) {

        var previousDefaultRowAnimation: UITableView.RowAnimation?
        if let animation = animation {
            previousDefaultRowAnimation = diffableDataSource.defaultRowAnimation
            diffableDataSource.defaultRowAnimation = animation
        }

        if let diffing = diffing {
            if #available(iOS 15.0, *), !animatingDifferences, !diffing {
                diffableDataSource.applySnapshotUsingReloadData(snapshot, completion: completion)
            } else {
                diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
            }
        } else {
            if #available(iOS 15.0, *), !animatingDifferences {
                diffableDataSource.applySnapshotUsingReloadData(snapshot, completion: completion)
            } else {
                diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
            }
        }

        if let previousDefaultRowAnimation = previousDefaultRowAnimation {
            diffableDataSource.defaultRowAnimation = previousDefaultRowAnimation
        }

        let isLoading: Bool
        if endLoadingOnCompletion {
            isLoading = false
        } else {
            isLoading = self.isLoading
        }

        if Thread.isMainThread {
            setIsLoading(isLoading, animated: animatingDifferences)    /// Updating the backgroundView
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.setIsLoading(isLoading,
                                   animated: animatingDifferences)    /// Updating the backgroundView on main thread
            }
        }
    }

    @available(iOS 14.0, *)
    func apply(_ snapshot: IQDiffableDataSourceSectionSnapshot,
               to section: IQSection,
               animatingDifferences: Bool = true,
               endLoadingOnCompletion: Bool = true,
               completion: (() -> Void)? = nil) {
        privateApply(snapshot, to: section, animatingDifferences: animatingDifferences,
                     endLoadingOnCompletion: endLoadingOnCompletion, completion: completion)
    }

    @available(iOS 14.0, *)
    private func privateApply(_ snapshot: IQDiffableDataSourceSectionSnapshot,
                              to section: IQSection,
                              animatingDifferences: Bool = true,
                              endLoadingOnCompletion: Bool = true,
                              completion: (() -> Void)? = nil) {

        diffableDataSource.apply(snapshot, to: section,
                                 animatingDifferences: animatingDifferences, completion: completion)

        let isLoading: Bool
        if endLoadingOnCompletion {
            isLoading = false
        } else {
            isLoading = self.isLoading
        }

        if Thread.isMainThread {
            setIsLoading(isLoading, animated: animatingDifferences)    /// Updating the backgroundView
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.setIsLoading(isLoading,
                                   animated: animatingDifferences)    /// Updating the backgroundView on main thread
            }
        }
    }
}
