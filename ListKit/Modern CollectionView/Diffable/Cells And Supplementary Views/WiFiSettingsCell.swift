//
//  WiFiSettingsCell.swift
//  ListKit
//
//  Created by Iftekhar on 2/4/23.
//

import UIKit
import IQListKit

@MainActor
protocol WiFiSettingsCellDelegate: AnyObject {
    func wifiCell(_ cell: WiFiSettingsCell, wifiStateChanged enabled: Bool)
}

class WiFiSettingsCell: UITableViewCell, IQModelableCell {

    weak var delegate: WiFiSettingsCellDelegate?

    struct Model: Hashable {
        let wifiEnabled: Bool
        let item: WiFiSettingsViewController.Item
    }

    var model: Model? {
        didSet {

            guard let model = model else { return }
            let item = model.item

            textLabel?.text = item.title

            // network cell
            if item.isNetwork {
                accessoryType = .detailDisclosureButton
                accessoryView = nil
            // configuration cells
            } else if item.isConfig {
                if item.type == .wifiEnabled {
                    let enableWifiSwitch = UISwitch()
                    enableWifiSwitch.isOn = model.wifiEnabled
                    enableWifiSwitch.addTarget(self, action: #selector(self.toggleWifi(_:)), for: .valueChanged)
                    accessoryView = enableWifiSwitch
                } else {
                    accessoryView = nil
                    accessoryType = .detailDisclosureButton
                }
            }
        }
    }

    @objc
    func toggleWifi(_ wifiEnabledSwitch: UISwitch) {
        delegate?.wifiCell(self, wifiStateChanged: wifiEnabledSwitch.isOn)
    }
}
