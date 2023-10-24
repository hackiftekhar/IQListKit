//
//  IQDiffableDataSourceSnapshotWrapper.swift
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

@globalActor
final public actor ReloadActor: GlobalActor {

    public static let shared: ReloadActor = ReloadActor()
    public typealias ActorType = ReloadActor
}

@ReloadActor
internal final class IQDiffableDataSourceSnapshotWrapper {

    private class NonIsolated {
        var removeDuplicatesWhenReloading: Bool = false
    }

    nonisolated var removeDuplicatesWhenReloading: Bool {
        get {
            nonIsolated.removeDuplicatesWhenReloading
        }
        set {
            nonIsolated.removeDuplicatesWhenReloading = newValue
        }
    }

    private let nonIsolated: NonIsolated = NonIsolated()

    var batchSnapshot: IQDiffableDataSourceSnapshot = IQDiffableDataSourceSnapshot()

    func reset(with snapshot: IQDiffableDataSourceSnapshot) {
        batchSnapshot = snapshot
    }
}
