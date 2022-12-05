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

import Foundation

// MARK: - Update the list
/// Note that all these methods can also be used in a background threads since they all
/// methods deal with the models, not any UI elements.
/// NSDiffableDataSourceSnapshot.apply is also background thread safe
public extension IQList {

    /// Performs the list reload
    /// - Parameters:
    ///   - updates: update block which will be called to generate the snapshot
    ///   - animatingDifferences: If true then animates the differences otherwise do not animate.
    ///   - completion: the completion block will be called after reloading the list
    func reloadData(_ updates: (_ snapshot: IQDiffableDataSourceSnapshot) -> Void,
                    updateExistingSnapshot: Bool = false,
                    animatingDifferences: Bool = true, animation: UITableView.RowAnimation? = nil,
                    endLoadingOnCompletion: Bool = true,
                    completion: (() -> Void)? = nil) {

        if updateExistingSnapshot {
            batchSnapshot = self.snapshot()
        } else {
            batchSnapshot = IQDiffableDataSourceSnapshot()
        }

        updates(batchSnapshot)
        apply(batchSnapshot, animatingDifferences: animatingDifferences, animation: animation, endLoadingOnCompletion: endLoadingOnCompletion, completion: completion)
    }

    func apply(_ snapshot: IQDiffableDataSourceSnapshot,
                    animatingDifferences: Bool = true, animation: UITableView.RowAnimation? = nil,
                    endLoadingOnCompletion: Bool = true,
                    completion: (() -> Void)? = nil) {

        if let reloadQueue = reloadQueue {
            reloadQueue.async { [weak self] in
                self?.privateApply(snapshot, animatingDifferences: animatingDifferences,
                                   animation: animation, endLoadingOnCompletion: endLoadingOnCompletion,
                                   completion: completion)
            }
        } else {
            self.privateApply(snapshot, animatingDifferences: animatingDifferences,
                              animation: animation, endLoadingOnCompletion: endLoadingOnCompletion,
                              completion: completion)
        }
    }

    private func privateApply(_ snapshot: IQDiffableDataSourceSnapshot,
                              animatingDifferences: Bool = true, animation: UITableView.RowAnimation? = nil,
                              endLoadingOnCompletion: Bool = true,
                              completion: (() -> Void)? = nil) {

        var previousDefaultRowAnimation: UITableView.RowAnimation?
        if let animation = animation {
            previousDefaultRowAnimation = diffableDataSource.defaultRowAnimation
            diffableDataSource.defaultRowAnimation = animation
        }

        if #available(iOS 15.0, *), !animatingDifferences {
            diffableDataSource.applySnapshotUsingReloadData(snapshot, completion: completion)
        } else {
            diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
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
            self.setIsLoading(isLoading, animated: animatingDifferences)    /// Updating the backgroundView
        } else {
            OperationQueue.main.addOperation {
                self.setIsLoading(isLoading,
                                  animated: animatingDifferences)    /// Updating the backgroundView on main thread
            }
        }
    }
}
