//
//  CustomNoItemView.swift
//  ListKit
//
//  Created by Iftekhar on 1/17/23.
//

import UIKit
import IQListKit

class CustomNoItemView: UIView, IQNoItemStateRepresentable {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var button: UIButton!

    func setIsLoading(_ isLoading: Bool, haveRecords: Bool, animated: Bool) {
        if isLoading {

            if haveRecords {
                titleLabel.isHidden = true
                subtitleLabel.isHidden = true
                button.isHidden = true
            } else {
                titleLabel.text = "Loading..."
                titleLabel.isHidden = false
                subtitleLabel.isHidden = true
                button.isHidden = true
            }

        } else if !haveRecords {
            titleLabel.isHidden = false
            subtitleLabel.isHidden = false
            button.isHidden = false
            titleLabel.text = "isLoading: \(isLoading)"
            subtitleLabel.text = "haveRecords: \(haveRecords)"
            button.setTitle("animated: \(animated)", for: .normal)
        } else {
            titleLabel.isHidden = true
            subtitleLabel.isHidden = true
            button.isHidden = true
        }
    }
}
