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
    @MainActor
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

    // swiftlint:disable line_length
    /// Performs the list reload
    /// - Parameters:
    ///   - updates: update block which will be called to generate the snapshot
    ///   - animatingDifferences: If true then animates the differences otherwise do not animate.
    ///   - completion: the completion block will be called after reloading the list
    nonisolated func reloadData(_ updates: @ReloadActor @escaping (_ builder: IQDiffableDataSourceSnapshotBuilder) -> Void,
                                updateExistingSnapshot: Bool = false,
                                animatingDifferences: Bool = true, diffing: Bool? = nil,
                                animation: UITableView.RowAnimation? = nil,
                                endLoadingOnCompletion: Bool = true,
                                completion: (@MainActor () -> Void)? = nil) {

        reloadQueue.async { @ReloadActor [removeDuplicates, registeredCells, registeredSupplementaryViews, cellRegisterType, existingSnapshot = self.snapshot(), weak self] in
            guard let self = self else { return }

            let initialSnapshot: IQDiffableDataSourceSnapshot
            if updateExistingSnapshot {
                initialSnapshot = existingSnapshot
            } else {
                initialSnapshot = IQDiffableDataSourceSnapshot()
            }

            let builder = IQDiffableDataSourceSnapshotBuilder(removeDuplicates: removeDuplicates,
                                                              registeredCells: registeredCells,
                                                              registeredSupplementaryViews: registeredSupplementaryViews,
                                                              batchSnapshot: initialSnapshot)

            updates(builder)

            let finalBatchSnapshot: IQDiffableDataSourceSnapshot = builder.batchSnapshot
            let newCells = builder.newCells
            let newSupplementaryViews = builder.newSupplementaryViews

            builder.newCells = []
            builder.newSupplementaryViews = [:]

            if newCells.isEmpty && newSupplementaryViews.isEmpty {
                privateApply(finalBatchSnapshot, animatingDifferences: animatingDifferences,
                             diffing: diffing, animation: animation,
                             endLoadingOnCompletion: endLoadingOnCompletion, completion: completion)
            } else if cellRegisterType == .manual {
                privateApply(finalBatchSnapshot, animatingDifferences: animatingDifferences,
                             diffing: diffing, animation: animation,
                             endLoadingOnCompletion: endLoadingOnCompletion, completion: completion)
            } else {
                DispatchQueue.main.async { @MainActor [weak self] in
                    guard let self = self else { return }

                    register(newCells: newCells, newSupplementaryViews: newSupplementaryViews)

                    reloadQueue.async { [weak self] in
                        guard let self = self else { return }

                        privateApply(finalBatchSnapshot, animatingDifferences: animatingDifferences,
                                     diffing: diffing, animation: animation,
                                     endLoadingOnCompletion: endLoadingOnCompletion, completion: completion)
                    }
                }
            }
        }
    }
    // swiftlint:enable line_length

    nonisolated
    func apply(_ snapshot: IQDiffableDataSourceSnapshot,
               animatingDifferences: Bool = true, diffing: Bool? = nil,
               animation: UITableView.RowAnimation? = nil,
               endLoadingOnCompletion: Bool = true,
               completion: (() -> Void)? = nil) {

        reloadQueue.async { [weak self] in
            guard let self = self else { return }

            privateApply(snapshot, animatingDifferences: animatingDifferences, diffing: diffing,
                         animation: animation, endLoadingOnCompletion: endLoadingOnCompletion,
                         completion: completion)
        }
    }

    nonisolated
    private func privateApply(_ snapshot: IQDiffableDataSourceSnapshot,
                              animatingDifferences: Bool = true, diffing: Bool? = nil,
                              animation: UITableView.RowAnimation? = nil,
                              endLoadingOnCompletion: Bool = true,
                              completion: (() -> Void)? = nil) {

        let previousDefaultRowAnimation: UITableView.RowAnimation?
        if let animation = animation {
            previousDefaultRowAnimation = self.defaultRowAnimation
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                diffableDataSource.defaultRowAnimation = animation
            }
        } else {
            previousDefaultRowAnimation = nil
        }

        if let diffing = diffing {
            if #available(iOS 15.0, *), !animatingDifferences, !diffing {
                diffableDataSource.applySnapshotUsingReloadData(snapshot,
                                                                completion: completion)
            } else {
                diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences,
                                         completion: completion)
            }
        } else {
            if #available(iOS 15.0, *), !animatingDifferences {
                diffableDataSource.applySnapshotUsingReloadData(snapshot,
                                                                completion: completion)
            } else {
                diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences,
                                         completion: completion)
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if let previousDefaultRowAnimation = previousDefaultRowAnimation {
                diffableDataSource.defaultRowAnimation = previousDefaultRowAnimation
            }
            let isLoading: Bool
            if endLoadingOnCompletion {
                isLoading = false
            } else {
                isLoading = self.isLoading
            }

            /// Updating the backgroundView
            setIsLoading(isLoading, animated: animatingDifferences)
        }
    }

    @available(iOS 14.0, *)
    nonisolated
    func apply(_ snapshot: IQDiffableDataSourceSectionSnapshot,
               to section: IQSection,
               animatingDifferences: Bool = true,
               endLoadingOnCompletion: Bool = true,
               completion: (() -> Void)? = nil) {
        reloadQueue.async { [weak self] in

            guard let self = self else { return }

            diffableDataSource.apply(snapshot, to: section,
                                     animatingDifferences: animatingDifferences, completion: {

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }

                    let isLoading: Bool
                    if endLoadingOnCompletion {
                        isLoading = false
                    } else {
                        isLoading = self.isLoading
                    }

                    setIsLoading(isLoading, animated: animatingDifferences)    /// Updating the backgroundView

                    completion?()
                }
            })
        }
    }
}

extension IQList {

    @available(*, unavailable, message: "This function is renamed to reloadData",
                renamed: "reloadData(_:animatingDifferences:endLoadingOnUpdate:completion:)")
    public func performUpdates(_ updates: () -> Void, animatingDifferences: Bool = true,
                               endLoadingOnUpdate: Bool = true,
                               completion: (() -> Void)? = nil) {
    }
}
