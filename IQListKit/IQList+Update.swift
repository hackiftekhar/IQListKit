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
}

// Async await version
public extension IQList {

    nonisolated
    func reloadData(_ updates: @Sendable @ReloadActor (_ builder: IQDiffableDataSourceSnapshotBuilder) -> Void,
                    updateExistingSnapshot: Bool = false,
                    animatingDifferences: Bool = true, diffing: Bool? = nil,
                    animation: UITableView.RowAnimation? = nil,
                    endLoadingOnCompletion: Bool = true) async {

        let removeDuplicates = removeDuplicates
        let registeredSupplementaryViews = registeredSupplementaryViews
        let registeredCells = registeredCells
        let cellRegisterType = cellRegisterType
        let existingSnapshot = self.snapshot()

        let initialSnapshot: IQDiffableDataSourceSnapshot
        if updateExistingSnapshot {
            initialSnapshot = existingSnapshot
        } else {
            initialSnapshot = IQDiffableDataSourceSnapshot()
        }

        let result = await buildSnapshot(removeDuplicates: removeDuplicates,
                                         registeredCells: registeredCells,
                                         registeredSupplementaryViews: registeredSupplementaryViews,
                                         initialSnapshot: initialSnapshot, updates: updates)

        if cellRegisterType == .automatic, !result.newCells.isEmpty || !result.newSupplementaryViews.isEmpty {
            await MainActor.run {
                // Registering new cells on main thread
                register(newCells: result.newCells, newSupplementaryViews: result.newSupplementaryViews)
            }
        }
        await apply(result.snapshot, animatingDifferences: animatingDifferences,
                    diffing: diffing, animation: animation,
                    endLoadingOnCompletion: endLoadingOnCompletion)
    }

    // swiftlint:disable line_length
    // swiftlint:disable large_tuple
    @ReloadActor
    private func buildSnapshot(removeDuplicates: Bool,
                               registeredCells: [any IQModelableCell.Type],
                               registeredSupplementaryViews: [String: [any IQModelableSupplementaryView.Type]],
                               initialSnapshot: IQDiffableDataSourceSnapshot,
                               updates: @Sendable @ReloadActor (_ builder: IQDiffableDataSourceSnapshotBuilder) -> Void)
    -> (snapshot: IQDiffableDataSourceSnapshot, newCells: [any IQModelableCell.Type], newSupplementaryViews: [String: [any IQModelableSupplementaryView.Type]]) {
        // swiftlint:enable line_length
        // swiftlint:enable large_tuple

        let builder = IQDiffableDataSourceSnapshotBuilder(removeDuplicates: removeDuplicates,
                                                          registeredCells: registeredCells,
                                                          registeredSupplementaryViews: registeredSupplementaryViews,
                                                          batchSnapshot: initialSnapshot)
        updates(builder)

        return (builder.batchSnapshot, builder.newCells, builder.newSupplementaryViews)
    }

    nonisolated
    func apply(_ snapshot: IQDiffableDataSourceSnapshot,
               animatingDifferences: Bool = true, diffing: Bool? = nil,
               animation: UITableView.RowAnimation? = nil,
               endLoadingOnCompletion: Bool = true) async {

        let previousDefaultRowAnimation: UITableView.RowAnimation?
        if let animation = animation {
            previousDefaultRowAnimation = self.defaultRowAnimation
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                diffableDataSource.defaultRowAnimation = animation
            }
        } else {
            previousDefaultRowAnimation = nil
        }

        let usingReloadData: Bool
        if let diffing = diffing {
            usingReloadData = !animatingDifferences && !diffing
        } else {
            usingReloadData = !animatingDifferences
        }

        await diffableDataSource.internalApply(snapshot, animatingDifferences: animatingDifferences,
                                               usingReloadData: usingReloadData)

        await MainActor.run { [weak self] in
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
               endLoadingOnCompletion: Bool = true) async {

        await diffableDataSource.internalApply(snapshot, to: section, animatingDifferences: animatingDifferences)

        await MainActor.run { [weak self] in
            guard let self = self else { return }

            let isLoading: Bool
            if endLoadingOnCompletion {
                isLoading = false
            } else {
                isLoading = self.isLoading
            }

            // Updating the backgroundView
            setIsLoading(isLoading, animated: animatingDifferences)
        }
    }
}

// Completion Handler version
public extension IQList {

    // swiftlint:disable line_length
    /// Performs the list reload
    /// - Parameters:
    ///   - updates: update block which will be called to generate the snapshot
    ///   - animatingDifferences: If true then animates the differences otherwise do not animate.
    ///   - completion: the completion block will be called after reloading the list
    nonisolated func reloadData(_ updates: @Sendable @ReloadActor @escaping (_ builder: IQDiffableDataSourceSnapshotBuilder) -> Void,
                                updateExistingSnapshot: Bool = false,
                                animatingDifferences: Bool = true, diffing: Bool? = nil,
                                animation: UITableView.RowAnimation? = nil,
                                endLoadingOnCompletion: Bool = true,
                                completion: ( @Sendable @MainActor () -> Void)? = nil) {
        // swiftlint:enable line_length
        Task.detached { [weak self] in
            guard let self = self else { return }
            await reloadData(updates, updateExistingSnapshot: updateExistingSnapshot,
                             animatingDifferences: animatingDifferences, diffing: diffing,
                             animation: animation, endLoadingOnCompletion: endLoadingOnCompletion)
            await MainActor.run {
                completion?()
            }
        }
    }

    nonisolated
    func apply(_ snapshot: IQDiffableDataSourceSnapshot,
               animatingDifferences: Bool = true, diffing: Bool? = nil,
               animation: UITableView.RowAnimation? = nil,
               endLoadingOnCompletion: Bool = true,
               completion: ( @Sendable @MainActor () -> Void)? = nil) {

        Task.detached { [weak self] in
            guard let self = self else { return }
            await apply(snapshot, animatingDifferences: animatingDifferences,
                        diffing: diffing, animation: animation,
                        endLoadingOnCompletion: endLoadingOnCompletion)
            await MainActor.run {
                completion?()
            }
        }
    }

    @available(iOS 14.0, *)
    nonisolated
    func apply(_ snapshot: IQDiffableDataSourceSectionSnapshot,
               to section: IQSection,
               animatingDifferences: Bool = true,
               endLoadingOnCompletion: Bool = true,
               completion: ( @Sendable @MainActor () -> Void)? = nil) {
        Task.detached { [weak self] in
            guard let self = self else { return }
            await apply(snapshot, to: section, animatingDifferences: animatingDifferences,
                        endLoadingOnCompletion: endLoadingOnCompletion)
            await MainActor.run {
                completion?()
            }
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
