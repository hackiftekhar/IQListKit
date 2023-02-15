/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Mimics the Settings.app for displaying a dynamic list of available wi-fi access points
*/

import UIKit
import IQListKit

class WiFiSettingsViewController: UIViewController {

    enum Section: CaseIterable {
        case config, networks
    }

    enum ItemType {
        case wifiEnabled, currentNetwork, availableNetwork
    }

    struct Item: Hashable {
        let title: String
        let type: ItemType
        let network: WiFiController.Network?

        init(title: String, type: ItemType) {
            self.title = title
            self.type = type
            self.network = nil
            self.identifier = UUID()
        }
        init(network: WiFiController.Network) {
            self.title = network.name
            self.type = .availableNetwork
            self.network = network
            self.identifier = network.identifier
        }
        var isConfig: Bool {
            let configItems: [ItemType] = [.currentNetwork, .wifiEnabled]
            return configItems.contains(type)
        }
        var isNetwork: Bool {
            return type == .availableNetwork
        }

        private let identifier: UUID
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.identifier)
        }
    }

    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    var wifiController: WiFiController! = nil
    lazy var configurationItems: [Item] = {
        return [Item(title: "Wi-Fi", type: .wifiEnabled),
                Item(title: "breeno-net", type: .currentNetwork)]
    }()

    private lazy var list = IQList(listView: tableView, delegateDataSource: self, defaultRowAnimation: .fade)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Wi-Fi"
        configureTableView()
        configureDataSource()
        updateUI(animated: false)
    }
}

extension WiFiSettingsViewController {

    func configureDataSource() {

        list.registerCell(type: WiFiSettingsCell.self, registerType: .class)

        wifiController = WiFiController { [weak self] (controller: WiFiController) in
            guard let self = self else { return }
            self.updateUI()
        }
        wifiController.scanForNetworks = true
    }

    /// - Tag: WiFiUpdate
    func updateUI(animated: Bool = true) {
        guard let controller = self.wifiController else { return }

        let configItems = configurationItems.filter { !($0.type == .currentNetwork && !controller.wifiEnabled) }

        list.reloadData({

            let configSection = IQSection(identifier: Section.config)
            list.append([configSection])

            let configModels: [WiFiSettingsCell.Model] = configItems.map {
                return WiFiSettingsCell.Model(wifiEnabled: wifiController.wifiEnabled, item: $0)
            }

            list.append(WiFiSettingsCell.self, models: configModels)

            if controller.wifiEnabled {
                let sortedNetworks = controller.availableNetworks.sorted { $0.name < $1.name }
                let networkItems = sortedNetworks.map { Item(network: $0) }

                let networkSection = IQSection(identifier: Section.networks)
                list.append([networkSection])

                let networkModels: [WiFiSettingsCell.Model] = networkItems.map {
                    return WiFiSettingsCell.Model(wifiEnabled: wifiController.wifiEnabled, item: $0)
                }
                list.append(WiFiSettingsCell.self, models: networkModels, section: networkSection)
            }

        }, animatingDifferences: animated)
    }
}

extension WiFiSettingsViewController {

    func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

extension WiFiSettingsViewController: IQListViewDelegateDataSource {
    func listView(_ listView: IQListView, modifyCell cell: IQListCell, at indexPath: IndexPath) {
        if let cell = cell as? WiFiSettingsCell {
            cell.delegate = self
        }
    }
}

extension WiFiSettingsViewController: WiFiSettingsCellDelegate {
    func wifiCell(_ cell: WiFiSettingsCell, wifiStateChanged enabled: Bool) {
        wifiController.wifiEnabled = enabled
        updateUI()
    }
}
