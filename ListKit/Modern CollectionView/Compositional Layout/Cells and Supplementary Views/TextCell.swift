/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Generic text cell
*/

import UIKit
import IQListKit

class TextCell: UICollectionViewCell, IQModelableCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    struct Model: Hashable {
        let text: String
        let cornerRadius: CGFloat
        let badgeCount: Int?
    }

    var model: Model? {
        didSet {
            guard let model = model else { return }

            label.text = "\(model.text)"
            contentView.backgroundColor = .cornflowerBlue
            contentView.layer.borderColor = UIColor.black.cgColor
            contentView.layer.borderWidth = 1
            contentView.layer.cornerRadius = model.cornerRadius
            label.textAlignment = .center
            label.font = UIFont.preferredFont(forTextStyle: .title1)
        }
    }
}

extension TextCell {
    func configure() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.minimumScaleFactor = 0.5
        contentView.addSubview(label)
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
            ])
    }
}
