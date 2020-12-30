//
//  UserViewController.swift
//
//  Created by Iftekhar on 11/12/20.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!

    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = user {
            title = user.name
            nameLabel.text = user.name
        }
    }
}
