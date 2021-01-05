import UIKit
import IQListKit

final class LabelCell: UICollectionViewCell, IQModelableCell {

    @IBOutlet var label: UILabel!

    var model: Mountain? {
        didSet {
            label.text = model?.name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.borderWidth = 1
        layer.cornerRadius = 16
        layer.borderColor = UIColor.lightGray.cgColor
    }

    static func estimatedSize(for model: AnyHashable?, listView: IQListView) -> CGSize {
        return size(for: model, listView: listView)
    }

    static func size(for model: AnyHashable?, listView: IQListView) -> CGSize {
        let column = 2
        let width = floor((listView.bounds.width - 10 * CGFloat(column + 1)) / CGFloat(column))
        return CGSize(width: width, height: 32)
    }
}
