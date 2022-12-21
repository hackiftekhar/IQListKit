//
//  InsertionSortViewController.swift
//  ListKit
//
//  Created by Iftekhar on 04/01/21.
//

import UIKit
import IQListKit

struct Node: Hashable {

    let sectionId: Int
    var value: Int
    var color: UIColor

    init(sectionId: Int, value: Int, maxValue: Int) {
        self.sectionId = sectionId
        let maxFloat: CGFloat = CGFloat(maxValue)
        let valueFloat: CGFloat = CGFloat(value)
        let hue = valueFloat / maxFloat
        self.value = value
        color = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(sectionId)
        hasher.combine(value)
        hasher.combine(color)
    }

    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.sectionId == rhs.sectionId && lhs.value == rhs.value
    }
}

final class InsertionSortViewController: UIViewController {

    final class Section: Hashable {

        let id: Int
        var nodes: [Node]
        private(set) var isSorted = false
        private var currentIndex = 1

        init(id: Int, count: Int) {
            self.id = id
            nodes = (0..<count).map { Node(sectionId: id, value: $0, maxValue: count) }.shuffled()
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        func sortNext() {
            guard !isSorted, nodes.count > 1 else {
                return isSorted = true
            }

            var index = currentIndex
            let currentNode = nodes[index]
            index -= 1

            while index >= 0 && currentNode.value < nodes[index].value {
                let node = nodes[index]
                nodes[index] = currentNode
                nodes[index + 1] = node
                index -= 1
            }

            currentIndex += 1

            if currentIndex >= nodes.count {
                isSorted = true
            }
        }

        static func == (lhs: Section, rhs: Section) -> Bool {
            return lhs.id == rhs.id
        }
    }

    @IBOutlet private var collectionView: UICollectionView!
    private var isSorting = false

    private var sections: [Section] = []
    private lazy var list = IQList(listView: collectionView)

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, style: .plain,
                                                            target: self, action: #selector(toggleSort))

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .zero
        }

        list.registerCell(type: InsertionCell.self, registerType: .class)

        updateSortButtonTitle()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        OperationQueue.main.addOperation {
            self.randmize(animated: true)
        }
    }

    @objc func toggleSort() {
        isSorting.toggle()
        updateSortButtonTitle()

        if isSorting {
            startInsertionSort()
        }
    }

    func updateSortButtonTitle() {
        navigationItem.rightBarButtonItem?.title = isSorting ? "Stop" : "Sort"
    }

    func randmize(animated: Bool) {

        let nodeSize = InsertionCell.size(for: nil, listView: collectionView)
        let rows = Int(collectionView.bounds.height / nodeSize.height) - 1
        let columns = Int(collectionView.bounds.width / nodeSize.width)
        sections.removeAll()
        for index in 0..<rows {
            let sectionIdentifier = Section(id: index, count: columns)
            sections.append(sectionIdentifier)
        }

        refreshUI(animated: animated)
    }

    func refreshUI(animated: Bool = true) {
        list.reloadData({
            for sectionIdentifier in sections {
                let section = IQSection(identifier: sectionIdentifier, headerSize: .zero, footerSize: .zero)
                list.append([section])

                list.append(InsertionCell.self, models: sectionIdentifier.nodes, section: section)
            }
        }, animatingDifferences: animated, completion: nil)
    }

    func startInsertionSort() {
        guard isSorting else {
            return
        }

        var isNextSortRequired = false

        for section in sections where !section.isSorted {
            section.sortNext()
            isNextSortRequired = true
        }

        if isNextSortRequired {
            refreshUI()
        }

        let milliseconds = UIDevice.current.userInterfaceIdiom == .phone ? 50 : 300
        let deadline: DispatchTime = DispatchTime.now() + .milliseconds(isNextSortRequired ? milliseconds : 1000)

        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            guard let self = self else {
                return
            }

            if !isNextSortRequired {
                self.randmize(animated: true)
            }
            self.startInsertionSort()
        }
    }
}
