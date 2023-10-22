//
//  IQDiffableDataSourceSnapshotWrapper.swift
//  IQListKit
//
//  Created by Iftekhar on 10/22/23.
//

import UIKit

internal final class IQDiffableDataSourceSnapshotWrapper {
    var removeDuplicatesWhenReloading: Bool = false

    var batchSnapshot: IQDiffableDataSourceSnapshot = IQDiffableDataSourceSnapshot()

    nonisolated func reset(with snapshot: IQDiffableDataSourceSnapshot) {
        batchSnapshot = snapshot
    }
}
