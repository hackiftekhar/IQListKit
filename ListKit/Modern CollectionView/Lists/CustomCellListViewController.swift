/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A compositional list layout using custom cells
*/

import UIKit
import IQListKit

@available(iOS 14.0, *)
class CustomCellListViewController: UIViewController {

    struct Item: Hashable {
        let category: Category
        let image: UIImage?
        let title: String?
        let description: String?
        init(category: Category, imageName: String? = nil, title: String? = nil, description: String? = nil) {
            self.category = category
            if let systemName = imageName {
                self.image = UIImage(systemName: systemName)
            } else {
                self.image = nil
            }
            self.title = title
            self.description = description
        }
        private let identifier = UUID()

        // swiftlint:disable line_length
        static let all = [
            Item(category: .music, imageName: "headphones", title: "Headphones",
                 description: "A portable pair of earphones that are used to listen to music and other forms of audio."),
            Item(category: .music, imageName: "hifispeaker.fill", title: "Loudspeaker",
                 description: "A device used to reproduce sound by converting electrical impulses into audio waves."),
            Item(category: .transportation, imageName: "airplane", title: "Plane",
                 description: "A commercial airliner used for long distance travel."),
            Item(category: .transportation, imageName: "tram.fill", title: "Tram",
                 description: "A trolley car used as public transport in cities."),
            Item(category: .transportation, imageName: "car.fill", title: "Car",
                 description: "A personal vehicle with four wheels that is able to carry a small number of people."),
            Item(category: .weather, imageName: "hurricane", title: "Hurricane",
                 description: "A tropical cyclone in the Caribbean with violent wind."),
            Item(category: .weather, imageName: "tornado", title: "Tornado",
                 description: "A destructive vortex of swirling violent winds that advances beneath a large storm system."),
            Item(category: .weather, imageName: "tropicalstorm", title: "Tropical Storm",
                 description: "A localized, intense low-pressure system, forming over tropical oceans."),
            Item(category: .weather, imageName: "snow", title: "Snow",
                 description: "Atmospheric water vapor frozen into ice crystals falling in light flakes.")
        ]
        // swiftlint:enable line_length
    }

    private enum Section: Hashable {
        case main
    }

    struct Category: Hashable {
        let icon: UIImage?
        let name: String?

        static let music = Category(icon: UIImage(systemName: "music.mic"), name: "Music")
        static let transportation = Category(icon: UIImage(systemName: "car"), name: "Transportation")
        static let weather = Category(icon: UIImage(systemName: "cloud.rain"), name: "Weather")
    }

    private lazy var list = IQList(listView: collectionView, delegateDataSource: self)
    private var collectionView: UICollectionView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "List with Custom Cells"
        configureHierarchy()
        configureDataSource()
    }
}

@available(iOS 14.0, *)
extension CustomCellListViewController {
    private func createLayout() -> UICollectionViewLayout {
        return IQCollectionViewLayout.listLayout(appearance: .plain)
    }
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
}

@available(iOS 14.0, *)
extension CustomCellListViewController {

    /// - Tag: CellRegistration
    private func configureDataSource() {

//        list.registerCell(type: CustomListCell.self, registerType: .class)

        list.reloadData({ [list] in

            let section = IQSection(identifier: Section.main)
            list.append([section])

            list.append(CustomListCell.self, models: Item.all)
        })
    }
}

@available(iOS 14.0, *)
extension CustomCellListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

@available(iOS 14.0, *)
extension CustomCellListViewController: IQListViewDelegateDataSource {

}
