import UIKit
import IQListKit

final class LabelCollectionCell: UICollectionViewCell, IQModelableCell {

    static private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    @IBOutlet var label: UILabel!

    typealias Model = MountainsController.Mountain
    var model: Model? {
        didSet {

            guard let model = model else { return }

            if let formattedHeight = Self.formatter.string(from: NSNumber(value: model.height)) {
                label.text = model.name + ", Height: \(formattedHeight)M"
            } else {
                label.text = model.name
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.borderWidth = 1
        layer.cornerRadius = 16
        layer.borderColor = UIColor.lightGray.cgColor
    }

    static func size(for model: Model, listView: IQListView) -> CGSize? {
        let column: CGFloat = 2
        let columnPlusOne: CGFloat = column + 1
        let width = floor((listView.bounds.width - 10 * columnPlusOne) / column)
        return CGSize(width: width, height: 32)
    }
}
