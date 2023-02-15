/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Cell for displaying the news item
*/

import UIKit
import IQListKit

class ConferenceNewsFeedCell: UICollectionViewCell, IQModelableCell {

    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let bodyLabel = UILabel()
    let separatorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    struct Model: Hashable {
        let section: UUID
        let item: ConferenceNewsController.NewsFeedItem
        let isLastCell: Bool
    }
    var model: Model? {
        didSet {
            guard let model = model else { return }

            titleLabel.text = model.item.title
            bodyLabel.text = model.item.body

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateLabel.text = dateFormatter.string(from: model.item.date)
            separatorView.isHidden = model.isLastCell
        }
    }
}

extension ConferenceNewsFeedCell {
    func configure() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.adjustsFontForContentSizeCategory = true
        dateLabel.adjustsFontForContentSizeCategory = true
        bodyLabel.adjustsFontForContentSizeCategory = true

        titleLabel.numberOfLines = 0
        bodyLabel.numberOfLines = 0

        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        dateLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        bodyLabel.font = UIFont.preferredFont(forTextStyle: .body)

        separatorView.backgroundColor = .placeholderText

        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(separatorView)

        let views = ["title": titleLabel, "date": dateLabel, "body": bodyLabel, "separator": separatorView]
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[title]-|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[date]", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[body]-|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[separator]-|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[title]-[date]-[body]-20-[separator(==1)]|",
            options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(constraints)
    }
}
