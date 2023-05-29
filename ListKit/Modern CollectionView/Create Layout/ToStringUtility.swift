//
//  ToStringUtility.swift
//  ListKit
//
//  Created by Iftekhar on 2/14/23.
//

import UIKit

extension UICollectionView.ScrollDirection {
    func toString() -> String {
        switch self {
        case .vertical:
            return ".vertical"
        case .horizontal:
            return ".horizontal"
        @unknown default:
            return ".unknown"
        }
    }
}

extension NSDirectionalEdgeInsets {
    func toString() -> String {
        return ".init(top: \(top), leading: \(leading), bottom: \(bottom), trailing: \(trailing))"
    }
}

extension UICollectionLayoutSectionOrthogonalScrollingBehavior {
    func toString() -> String {
        switch self {
        case .none:
            return ".none"
        case .continuous:
            return ".continuous"
        case .continuousGroupLeadingBoundary:
            return ".continuousGroupLeadingBoundary"
        case .paging:
            return ".paging"
        case .groupPaging:
            return ".groupPaging"
        case .groupPagingCentered:
            return ".groupPagingCentered"
        @unknown default:
            return ".none"
        }
    }
}

extension NSCollectionLayoutSpacing {
    func toString() -> String {

        if isFlexible {
            return ".flexible(\(spacing))"
        } else if isFixed {
            return ".fixed(\(spacing))"
        } else {
            return "Unknown"
        }
    }
}

// swiftlint:disable line_length
extension NSCollectionLayoutEdgeSpacing {

    func toString() -> String {
        return "NSCollectionLayoutEdgeSpacing(leading: \(leading?.toString() ?? "nil"), top: \(top?.toString() ?? "nil"), trailing: \(trailing?.toString() ?? "nil"), bottom: \(bottom?.toString() ?? "nil"))"
    }

    var isEmpty: Bool {
        if trailing == nil, leading == nil, top == nil, bottom == nil {
            return true
        }

        guard let trailing = trailing, let leading = leading, let top = top, let bottom = bottom else {
            return false
        }

        guard leading.isFixed && leading.spacing == 0 else {
            return false
        }

        guard trailing.isFixed && trailing.spacing == 0 else {
            return false
        }

        guard top.isFixed && top.spacing == 0 else {
            return false
        }

        guard bottom.isFixed && bottom.spacing == 0 else {
            return false
        }
        return true
    }
}

extension NSCollectionLayoutDimension {

    func toString() -> String {

        if isFractionalWidth {
            return ".fractionalWidth(\(dimension))"
        } else if isFractionalHeight {
            return ".fractionalHeight(\(dimension))"
        } else if isAbsolute {
            return ".absolute(\(dimension))"
        } else if isEstimated {
            return ".estimated(\(dimension))"
        } else {
            return ".unknown"
        }
    }
}

extension NSCollectionLayoutSize {

    func toString() -> String {

        return "NSCollectionLayoutSize(widthDimension: \(widthDimension.toString()), heightDimension: \(heightDimension.toString()))"
    }
}
