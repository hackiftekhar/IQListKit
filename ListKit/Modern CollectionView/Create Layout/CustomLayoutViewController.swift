//
//  CustomLayoutViewController.swift
//  ListKit
//
//  Created by Iftekhar on 2/13/23.
//

import UIKit
import IQListKit

@available(iOS 14.0, *)
class CustomLayoutViewController: UIViewController {

    enum Section: Int, CaseIterable {
        case one
        case two
        case three
    }

    var collectionView: UICollectionView! = nil
    var layout = CreateLayoutViewController.Layout()

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)

    private lazy var createLayoutController = CreateLayoutViewController()
    private lazy var createLayoutNavigationController = UINavigationController(rootViewController: createLayoutController)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Grid"
        configureHierarchy()
        configureDataSource()
    }
}

@available(iOS 14.0, *)
extension CustomLayoutViewController {

    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout.create())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)

        let editBarButton = UIBarButtonItem(barButtonSystemItem: .compose,
                                            target: self, action: #selector(editLayout(_:)))
        self.navigationItem.rightBarButtonItem = editBarButton

        do {
            createLayoutController.layout = self.layout
            createLayoutController.delegate = self
        }
    }
}

@available(iOS 14.0, *)
extension CustomLayoutViewController {
    private func configureDataSource() {

        list.registerCell(type: TextCell.self, registerType: .class)

        list.reloadData { [self] in

            for aSection in Section.allCases {
                let section = IQSection(identifier: aSection)
                list.append([section])

                let items: [TextCell.Model] = Array(0..<10).map { .init(text: "\(aSection.rawValue):\($0)", cornerRadius: 0, badgeCount: 0) }
                list.append(TextCell.self, models: items)
            }
        }
    }
}

@available(iOS 14.0, *)
extension CustomLayoutViewController: CreateLayoutViewControllerDelegate, UIPopoverPresentationControllerDelegate {

    @objc private func editLayout(_ button: UIBarButtonItem) {
        createLayoutController.layout = self.layout
        createLayoutNavigationController.modalPresentationStyle = .popover
        createLayoutNavigationController.popoverPresentationController?.barButtonItem = button

        let heightWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        createLayoutNavigationController.preferredContentSize = CGSize(width: heightWidth, height: heightWidth)
        createLayoutNavigationController.popoverPresentationController?.delegate = self
        self.present(createLayoutNavigationController, animated: true)
    }

    func createLayoutController(_ controller: CreateLayoutViewController,
                                didUpdate layout: CreateLayoutViewController.Layout) {
        self.layout = layout
        collectionView.collectionViewLayout = layout.create()
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
    }
}

@available(iOS 14.0, *)
extension CustomLayoutViewController: IQListViewDelegateDataSource {
}
