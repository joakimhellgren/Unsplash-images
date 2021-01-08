import UIKit


class ViewController : UIViewController, UISearchBarDelegate, UICollectionViewDelegate {
    
    
    var searchController = UISearchController()
    let isUserLoggedIn: Bool = false
    var dataManager = DataManager()
    // api data / trackers
    var images: [Result] = []
    var totalCount = 0
    var currentCount = 0
    var page = 1
    var searchInput: String?
    
    // prevent fetch from requesting data when a request is already in progress.
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
        popupBackgroundView.backgroundColor = .systemOrange
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
        popupBackgroundView.frame = view.bounds
        
        view.addSubview(popupBackgroundView)
        let popupViewSize = popupBackgroundView.frame.size.width - 1.125
        
        popupView.frame = CGRect(x: 0, y: 0, width: popupViewSize, height: popupViewSize + 64)
        popupView.center = CGPoint(x: view.center.x, y: view.center.y - (view.center.y / 4))
        //popupView.alpha = 0
        popupView.backgroundColor = .secondarySystemBackground
        view.addSubview(popupView)
        
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: popupView.frame.size.width - 32, height: 54))
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle:  .title2)
        titleLabel.textAlignment = .center
        popupView.addSubview(titleLabel)
        
        let messageLabel = UILabel(frame: CGRect(x: 16, y: 40, width: popupView.frame.size.width - 32, height: 64))
        messageLabel.numberOfLines = 0
        messageLabel.font = .preferredFont(forTextStyle: .subheadline)
        messageLabel.text = message
        messageLabel.textAlignment = .center
        popupView.addSubview(messageLabel)
        
        let emailField: UITextField = {
            let emailField = UITextField()
            emailField.frame = CGRect(x: 16, y: popupView.frame.size.height - 324, width: popupView.frame.size.width - 32, height: 40)
            emailField.placeholder = "Email"
            let lineView = UIView(frame: CGRect(x: 0, y: emailField.frame.size.height, width: emailField.frame.size.width, height: 0.5))
            lineView.alpha = 0.75
            lineView.backgroundColor = .opaqueSeparator
            emailField.addSubview(lineView)
            return emailField
        }()
        popupView.addSubview(emailField)
        
        let passwordField: UITextField = {
            let passwordField = UITextField()
            passwordField.frame = CGRect(x: 16, y: popupView.frame.size.height - 252, width: popupView.frame.size.width - 32, height: 40)
            passwordField.placeholder = "Password"
            passwordField.isSecureTextEntry = true
            let lineView = UIView(frame: CGRect(x: 0, y: passwordField.frame.size.height, width: passwordField.frame.size.width, height: 0.5))
            lineView.alpha = 0.75
            lineView.backgroundColor = .opaqueSeparator
            let forgotPass = UIButton(type: .system, primaryAction: UIAction(title: "Forgot password?", handler: { _ in return }))
            forgotPass.frame = CGRect(x: 0, y: passwordField.frame.size.height + 16, width: passwordField.frame.size.width, height: 20)
            forgotPass.contentHorizontalAlignment = .trailing
            passwordField.addSubview(lineView)
            passwordField.addSubview(forgotPass)
            return passwordField
        }()
        popupView.addSubview(passwordField)
        
        let loginButton = UIButton(type: .system, primaryAction: UIAction(title: "Log in", handler: { _ in self.dismissPopup() }))
        loginButton.frame = CGRect(x: 16, y: popupView.frame.size.height - 128, width: popupView.frame.size.width - 32, height: 48)
        loginButton.backgroundColor = .systemBackground
        popupView.addSubview(loginButton)
        
        let registerButton = UIButton(type: .system, primaryAction: UIAction(title: "Register", handler: { _ in return }))
        registerButton.frame = CGRect(x: 16, y: popupView.frame.size.height - 64, width: popupView.frame.size.width - 32, height: 48)
        registerButton.backgroundColor = .systemBackground
        popupView.addSubview(registerButton)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.popupBackgroundView.alpha = 1
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.popupView.alpha = 1
                })
            }
        })
    }
    
    func dismissPopup() {
        UIView.animate(withDuration: 0.25, animations: {
            self.popupBackgroundView.alpha = 0
        }, completion: { done in
                    if done {
                        
                        self.popupView.removeFromSuperview()
                        self.popupBackgroundView.removeFromSuperview()
                        self.navigationController?.navigationBar.alpha = 1
                        
                        self.collectionView.bounces = true
                    }
                
            }
        )
        searchController.searchBar.isUserInteractionEnabled = true
        
    }
    
    
    
    
    
    // MARK: DiffableDataSource configuration
    
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
    
    
    
    
    // MARK: Collection view configuration
    
    private lazy var collectionView: UICollectionView = {
        
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionView.register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "sampleFooterIdentifier")
        return collectionView
    }()
    
    
    
    
    // MARK: other
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if showPopupMessage == true {
           
            collectionView.bounces = false
            navigationController?.navigationBar.alpha = 0
            searchController.searchBar.isUserInteractionEnabled = false
            switch isUserLoggedIn {
            case false:
                let RGAppNames = [
                    "Unsplashify",
                    "Imagify",
                    "unSplashed",
                    "PicSearchify",
                    "Picstagram",
                    "Unsplashtagram",
                    "Splashify"
                ]
                guard let randomAppName = RGAppNames.randomElement() else { return }
                showPopup(with: "Hi there, stranger.", message: "Welcome to \(randomAppName), please log in to continue.", on: self)
            case true:
                return
            }
            showPopupMessage = false
        }
        
    }
    
    
}
