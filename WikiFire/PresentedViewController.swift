import UIKit
import DrawerKit
import Firebase

class PresentedViewController: UIViewController {
    private var notificationToken: NotificationToken!

    @IBOutlet weak var presentedView: PresentedView!
    @IBAction func dismissButtonTapped() {
        dismiss(animated: true)
    }

    var curid: String? {
        didSet {
            checkIfVisited()
            fetchWikipediaInformation(curid: curid!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.notificationToken = NotificationCenter.default
            .addObserver(name: DrawerNotification.drawerExteriorTappedNotification) {
            (notification: DrawerNotification, object: Any?) in
            switch notification {
            case .drawerExteriorTapped:
                print("drawerExteriorTapped")
            default:
                break
            }
        }
    }

    func checkIfVisited() {

        let ref = Database.database().reference()
        ref.child("visitors").child(Auth.auth().currentUser!.uid).child(curid!).observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() {
                print("Not visited yet.")
                DispatchQueue.main.async {
                    self.presentedView.checkImageView.image = #imageLiteral(resourceName: "new")
                }
                ref.child("visitors").child(Auth.auth().currentUser!.uid).child(self.curid!).setValue(true)
            }else {
                print("Visited before.")
                DispatchQueue.main.async {
                    self.presentedView.checkImageView.image = #imageLiteral(resourceName: "check")
                }
            }
        }

    }

    func fetchWikipediaInformation(curid: String) {

        let string = String(format:"https://no.wikipedia.org/w/api.php?action=query&prop=pageimages|images|info|extracts&pageids=\(curid)&inprop=url&format=json&exlimit=max&explaintext&exintro")

        if let url = URL(string: string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!){
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 10
            _ = URLSession.shared.dataTask(with: request) { data, response, error in

                // check for fundamental networking error
                guard let data = data, error == nil else {
                    if let local = error?.localizedDescription {
                        print(local)
                    }
                    return
                }

                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print(httpStatus.statusCode)
                    return
                }

                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]

                    if let query = result!["query"] as? [String: Any] {
                        if let pages = query["pages"] as? [String: Any] {
                            if let page = pages.first?.value as? [String: Any] {
                                if let extract = page["extract"] as? String, let title = page["title"] as? String {
                                    DispatchQueue.main.async {
                                        self.presentedView.titleLabel.text = title
                                        self.presentedView.wikiLabel.text = extract
                                        //self.presentedView.bodyLabel.text = extract
                                    }

                                    if let images = page["images"] as? [Any] {

                                        for image in images {
                                            if let dict = image as? [String: Any] {
                                                if let title = dict["title"] as? String {
                                                    if title.lowercased().contains("jpg") || title.lowercased().contains("png") {
                                                        let formattedTitle = title.replacingOccurrences(of: "Fil", with: "File")
                                                        //let charFormattedTitle = formattedTitle.replacingOccurrences(of: " ", with: "%20")
                                                        let imageMetaURL = "https://commons.wikimedia.org/w/api.php?action=query&titles=\(formattedTitle)&prop=imageinfo&iiprop=url&format=json"
                                                        self.requestImage(url: imageMetaURL)
                                                        print("Found jpg or png.")
                                                        break
                                                    }
                                                }
                                            }
                                        }
                                    }

                                }

                            }
                        }
                    }

                } catch {
                    print("Error -> \(error)")
                }

                }.resume()
        }else{
            print("Problem...")
        }

    }

    func requestImage(url: String) {

        if let url = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!){
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 10
            _ = URLSession.shared.dataTask(with: request) { data, response, error in

                // check for fundamental networking error
                guard let data = data, error == nil else {
                    if let local = error?.localizedDescription {
                        print(local)
                    }
                    return
                }

                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print(httpStatus.statusCode)
                    return
                }

                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]

                    if let query = result!["query"] as? [String: Any] {
                        if let pages = query["pages"] as? [String: Any] {
                            if let page = pages.first?.value as? [String: Any] {
                                if let imageInfo = page["imageinfo"] as? [[String: Any]] {
                                    if let imageURL = imageInfo.first!["url"] as? String {
                                        DispatchQueue.main.async {
                                            print("Trying to download \(imageURL)")
                                            self.presentedView.wikiImageView.downloadedFrom(link: imageURL)
                                        }
                                    }
                                }
                            }
                        }
                    }

                } catch {
                    print("Error -> \(error)")
                }

                }.resume()
        }else{
            print("Problem...")
        }

    }

    @IBAction func unwindFromModal(with segue: UIStoryboardSegue) {}
}

extension PresentedViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return (view as? PresentedView)?.imageView
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}

extension PresentedViewController: DrawerPresentable {
    var heightOfPartiallyExpandedDrawer: CGFloat {
        guard let view = self.view as? PresentedView else { return 0 }
        return view.dividerView.frame.origin.y
    }
}

extension PresentedViewController: DrawerAnimationParticipant {
    public var drawerAnimationActions: DrawerAnimationActions {
        let prepareAction: DrawerAnimationActions.PrepareHandler = {
            [weak self] info in
            switch (info.startDrawerState, info.endDrawerState) {
            case (.collapsed, .partiallyExpanded):
                self?.presentedView.prepareCollapsedToPartiallyExpanded()
            case (.partiallyExpanded, .collapsed):
                self?.presentedView.preparePartiallyExpandedToCollapsed()
            case (.collapsed, .fullyExpanded):
                self?.presentedView.prepareCollapsedToFullyExpanded()
            case (.fullyExpanded, .collapsed):
                self?.presentedView.prepareFullyExpandedToCollapsed()
            case (.partiallyExpanded, .fullyExpanded):
                self?.presentedView.preparePartiallyExpandedToFullyExpanded()
            case (.fullyExpanded, .partiallyExpanded):
                self?.presentedView.prepareFullyExpandedToPartiallyExpanded()
            default:
                break
            }
        }

        let animateAlongAction: DrawerAnimationActions.AnimateAlongHandler = {
            [weak self] info in
            switch (info.startDrawerState, info.endDrawerState) {
            case (.collapsed, .partiallyExpanded):
                self?.presentedView.animateAlongCollapsedToPartiallyExpanded()
            case (.partiallyExpanded, .collapsed):
                self?.presentedView.animateAlongPartiallyExpandedToCollapsed()
            case (.collapsed, .fullyExpanded):
                self?.presentedView.animateAlongCollapsedToFullyExpanded()
            case (.fullyExpanded, .collapsed):
                self?.presentedView.animateAlongFullyExpandedToCollapsed()
            case (.partiallyExpanded, .fullyExpanded):
                self?.presentedView.animateAlongPartiallyExpandedToFullyExpanded()
            case (.fullyExpanded, .partiallyExpanded):
                self?.presentedView.animateAlongFullyExpandedToPartiallyExpanded()
            default:
                break
            }
        }

        let cleanupAction: DrawerAnimationActions.CleanupHandler = {
            [weak self] info in
            switch (info.startDrawerState, info.endDrawerState) {
            case (.collapsed, .partiallyExpanded):
                self?.presentedView.cleanupCollapsedToPartiallyExpanded()
            case (.partiallyExpanded, .collapsed):
                self?.presentedView.cleanupPartiallyExpandedToCollapsed()
            case (.collapsed, .fullyExpanded):
                self?.presentedView.cleanupCollapsedToFullyExpanded()
            case (.fullyExpanded, .collapsed):
                self?.presentedView.cleanupFullyExpandedToCollapsed()
            case (.partiallyExpanded, .fullyExpanded):
                self?.presentedView.cleanupPartiallyExpandedToFullyExpanded()
            case (.fullyExpanded, .partiallyExpanded):
                self?.presentedView.cleanupFullyExpandedToPartiallyExpanded()
            default:
                break
            }
        }

        return DrawerAnimationActions(prepare: prepareAction,
                                      animateAlong: animateAlongAction,
                                      cleanup: cleanupAction)
    }
}
