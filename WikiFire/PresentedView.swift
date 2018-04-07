import UIKit

class PresentedView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var wikiLabel: UILabel!
    @IBOutlet weak var wikiImageView: UIImageView!
}

extension PresentedView {
    func prepareCollapsedToPartiallyExpanded() {
        titleLabel.alpha = 0
        bodyLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
    }

    func animateAlongCollapsedToPartiallyExpanded() {
        titleLabel.alpha = 1
        bodyLabel.transform = .identity
    }

    func cleanupCollapsedToPartiallyExpanded() {
        animateAlongCollapsedToPartiallyExpanded()
    }

    func preparePartiallyExpandedToCollapsed() {
        animateAlongCollapsedToPartiallyExpanded()
    }

    func animateAlongPartiallyExpandedToCollapsed() {
        prepareCollapsedToPartiallyExpanded()
    }

    func cleanupPartiallyExpandedToCollapsed() {
        prepareCollapsedToPartiallyExpanded()
    }
}

extension PresentedView {
    func preparePartiallyExpandedToFullyExpanded() {
        bodyLabel.transform = .identity
    }

    func animateAlongPartiallyExpandedToFullyExpanded() {
        bodyLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
    }

    func cleanupPartiallyExpandedToFullyExpanded() {
        animateAlongPartiallyExpandedToFullyExpanded()
    }

    func prepareFullyExpandedToPartiallyExpanded() {
        animateAlongPartiallyExpandedToFullyExpanded()
    }

    func animateAlongFullyExpandedToPartiallyExpanded() {
        preparePartiallyExpandedToFullyExpanded()
    }

    func cleanupFullyExpandedToPartiallyExpanded() {
        preparePartiallyExpandedToFullyExpanded()
    }
}

extension PresentedView {
    func prepareCollapsedToFullyExpanded() {
        bodyLabel.transform = .identity
    }

    func animateAlongCollapsedToFullyExpanded() {
        bodyLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
    }

    func cleanupCollapsedToFullyExpanded() {
        animateAlongCollapsedToFullyExpanded()
    }

    func prepareFullyExpandedToCollapsed() {
        animateAlongCollapsedToFullyExpanded()
    }

    func animateAlongFullyExpandedToCollapsed() {
        prepareCollapsedToFullyExpanded()
    }

    func cleanupFullyExpandedToCollapsed() {
        prepareCollapsedToFullyExpanded()
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
