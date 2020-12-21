import UIKit


class ViewController : UIViewController, UISearchBarDelegate, UICollectionViewDelegate {

    
    // MARK: Bindings & logic
    var searchController = UISearchController()
    
    // api
    var dataManager = DataManager()
    // api response
    var images: [Result] = []
    var totalCount = 0
    var currentCount = 0
    // api queries
    var page = 1
    var searchInput: String?
    // prevent methods from requesting data when a request is already in progress.
    var prefetchState: PrefetchState = .idle
    enum PrefetchState {
        case fetching
        case idle
    }
    
    // sets the text of the footer textLabel depending on which case we specify in our collection supplementary view
    var footerState = StatusLabelText.blank
    enum StatusLabelText {
        case loading
        case endOfResult
        case blank
    }
    
    //MARK: Welcome message configuration
    private var showPopupMessage = true
    private let popupBackgroundView: UIView = {
       let popupBackgroundView = UIView()
        popupBackgroundView.backgroundColor = .black
        popupBackgroundView.alpha = 0
        return popupBackgroundView
    }()
    private let popupView: UIView = {
       let popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.masksToBounds = true
        popupView.layer.cornerRadius = 12
        return popupView
    }()
    
    func showPopup(with title: String, message: String, on viewController: ViewController) {
        popupBackgroundView.frame = self.view.bounds
        self.view.addSubview(popupBackgroundView)
        popupView.frame = CGRect(x: 40, y: -300, width: self.view.frame.size.width - 80, height: 300)
        popupView.center = CGPoint(x: 210, y: 250)
        popupView.alpha = 0
        popupView.backgroundColor = .secondarySystemBackground
        self.view.addSubview(popupView)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: popupView.frame.size.width, height: 60))
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle:  .title2)
        titleLabel.textAlignment = .center
        popupView.addSubview(titleLabel)
        
        

        let messageLabel = UILabel(frame: CGRect(x: 16, y: 34, width: popupView.frame.size.width - 32, height: 60))
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.textAlignment = .center
        popupView.addSubview(messageLabel)
        
        let emailField: UITextField = {
            let emailField = UITextField()
            emailField.frame = CGRect(x: 16, y: popupView.frame.size.height - 200, width: popupView.frame.size.width - 32, height: 40)
            emailField.placeholder = "Email"
            emailField.layer.borderWidth = 1
            emailField.borderStyle = .roundedRect
            emailField.layer.borderColor = UIColor.black.cgColor
            return emailField
        }()
        popupView.addSubview(emailField)
        
        let passwordField: UITextField = {
            let passwordField = UITextField()
            passwordField.frame = CGRect(x: 16, y: popupView.frame.size.height - 148, width: popupView.frame.size.width - 32, height: 40)
            passwordField.borderStyle = .roundedRect
            passwordField.placeholder = "Password"
            passwordField.layer.borderWidth = 1
            passwordField.layer.borderColor = UIColor.black.cgColor
            passwordField.isSecureTextEntry = true
            return passwordField
        }()
        popupView.addSubview(passwordField)
        
        let button = UIButton(type: .system, primaryAction: UIAction(title: "Log in", handler: { _ in self.dismissPopup() }))
        button.frame = CGRect(x: 0, y: popupView.frame.size.height - 50, width: popupView.frame.size.width, height: 50)
        // button.setTitle("Thanks, I guess?", for: .normal)
        // button.setTitleColor(.link, for: .normal)
        popupView.addSubview(button)
        
        let forgotPasswordButton = UIButton(type: .detailDisclosure, primaryAction: UIAction(title: "Forgot password?", handler: { _ in print("churf") }))
        forgotPasswordButton.frame = CGRect(x: 0, y: popupView.frame.size.height - 10, width: popupView.frame.size.width, height: 50)
        popupView.addSubview(forgotPasswordButton)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.popupBackgroundView.alpha = 0.6
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    self.popupView.center = CGPoint(x: 210, y: 300)
                    self.popupView.alpha = 1
                })
            }
        })
        
    }
    
    func dismissPopup() {
        UIView.animate(withDuration: 0.25, animations: {
            self.popupView.alpha = 0
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    self.popupBackgroundView.alpha = 0
                }, completion: { done in
                    if done {
                        self.popupView.removeFromSuperview()
                        self.popupBackgroundView.removeFromSuperview()
                    }
                })
            }
        })
        searchController.searchBar.isUserInteractionEnabled = true
    }
    
    
    
    
    
     // MARK: DDS configuration
    private lazy var diffableDataSource: UICollectionViewDiffableDataSource<Int, Result> = {
        let dataSource = UICollectionViewDiffableDataSource<Int, Result>(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
            cell.configure(label: self.images[indexPath.row].user.username, image: self.images[indexPath.row].urls.small)
            return cell
        }
        // footer
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            switch kind {
            case UICollectionView.elementKindSectionFooter:
                guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sampleFooterIdentifier", for: indexPath) as? CollectionReusableView
                else {
                    print("error implementing footerView")
                    return UICollectionReusableView()
                }
                // set state of activity indicator in footer
                var loading: Bool {
                    switch self.footerState {
                    case .loading:
                        return true
                    case .endOfResult, .blank:
                        return false
                    }
                }
                // set state of text label in footer
                var text: String {
                    switch self.footerState {
                    case .endOfResult:
                        return "Nothing here."
                    case .blank, .loading:
                        return " "
                    }
                }
                footerView.fill(with: text, loading: loading)
                return footerView
            default:
                print("error implementing \(kind)")
                return UICollectionReusableView()
            }
        }
        return dataSource
    }()
    
    
     // MARK: Collection view configuration
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.footerReferenceSize = CGSize(width: 0, height: 60)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionView.register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "sampleFooterIdentifier")
        return collectionView
    }()
    
    // Let's user navigate to a new page with more information on the image clicked
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let view = mainStoryboard.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController
        let image = images[indexPath.row]
        view.configure(user: image.user.username, image: image.urls.regular, date: "created: \(image.created_at)", description: image.description ?? "no description available")
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    // pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let input = searchInput, currentCount > 0, page > 1, indexPath.row == images.count - 1 {
            fetchData(searchTerm: input, page: page)
        }
    }
    
    // update the collection view cells / footer with our requested data
    private func update(with items: [Result]) {
        // compares new data with current data and updates cells/view if any changes were made.
        var snapshot = NSDiffableDataSourceSnapshot<Int, Result>()
        snapshot.appendSections([0])
        snapshot.appendItems(images, toSection: 0)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func resetDataForNewSearch() {
        images = []
        currentCount = 0
        totalCount = 0
        page = 1
    }
    
    //MARK: Searchbar configuration
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resetDataForNewSearch()
        if let input = self.searchController.searchBar.text {
            title = "Searching for: \(input)"
            fetchData(searchTerm: input, page: page)
        }
        searchController.isActive = false
    }
    
    
    //MARK: API configuration
    private func fetchData(searchTerm: String, page: Int) {
        if prefetchState == .fetching { return }
        // set prefetchState to .fetching to prevent fetchData from triggering when a call is already in progress..
        prefetchState = .fetching
        // store users search word globally (used when paginating)
        searchInput = searchTerm
        // fetch data from API and pass it into our request handler method below this block of code.
        dataManager.fetch(page: page, searchTerm: searchTerm) { images in
            self.responseHandler(result: images)
        }
        prefetchState = .idle
    }
    
    // handle the data that we get from the fetchData method.
    private func responseHandler(result: Images) {
        if result.results.isEmpty { footerState = .endOfResult }
        else {
            images.append(contentsOf: result.results)
            currentCount += result.results.count
            totalCount = result.total
            page += 1
            footerState = .loading
            if currentCount == totalCount { footerState = .endOfResult }
        }
        update(with: images)
    }
    
    
    override func loadView() {
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = diffableDataSource
        collectionView.delegate = self
        searchController.searchBar.placeholder = "Search.."
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        //title = ""
    }
    
    let isUserLoggedIn: Bool = false
    let RGAppNames = [
        "Unsplashify",
        "Imagify",
        "unSplashed",
        "PicSearchify",
        "Picstagram",
        "Unsplashtagram",
        "Splashify"
    ]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showPopupMessage == true {
            searchController.searchBar.isUserInteractionEnabled = false
            if !isUserLoggedIn {
                let RNG = RGAppNames.randomElement()
                showPopup(with: "Hi there, stranger.", message: "Login or become a part of \(RNG ?? "our community")!", on: self)
            }
            
            showPopupMessage = false
        }
    }
    
}
