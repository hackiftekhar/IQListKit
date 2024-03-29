//
//  Array+Extension.swift
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

internal extension Array where Element: Hashable {

    /// Return unique and duplicate elements from array (and an option to pass existing elements)
    @discardableResult
    nonisolated
    func removeDuplicate(existingElements: [Element] = []) -> (unique: [Element], duplicate: [Element]) {

        var duplicate: [Element] = []
        // Storing indexes of each element
        var hashTable: [Element: Int] = self.enumerated().reduce(into: [Element: Int]()) { result, object in
            if result[object.element] == nil {
                result[object.element] = object.offset
            } else {
                // If this object already exist then it's a duplicate
                duplicate.append(object.element)
            }
        }

        var unique: [Element] = []
        self.forEach { element in
            if hashTable[element] != nil {
                hashTable[element] = nil
                unique.append(element)
            }
        }

        return (unique, duplicate)
    }
}
