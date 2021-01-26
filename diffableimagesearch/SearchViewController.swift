import UIKit


class SearchViewController : UIViewController, UISearchBarDelegate, UICollectionViewDelegate {
    
    
    // API
    var dataManager = API()
    // parameters / trackers
    var images: [Image] = []
    var totalCount = 0
    var currentCount = 0
    var page = 1
    var searchInput: String?
    
    
    //MARK: - API methods & config
    func update(with items: [Image]) {
        // compare new data with any existing data in diffable data source and update any changes.
        var snapshot = NSDiffableDataSourceSnapshot<Int, Image>()
        snapshot.appendSections([0])
        snapshot.appendItems(images, toSection: 0)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    // handle the data that we get from the fetchData method.
    func responseHandler(result: Images) {
        if result.results.isEmpty {
            // state to tell our footer view to display information about our search result depending on the response from the server.
            footerState = .endOfResult
            update(with: images)
        }
        else {
            images.append(contentsOf: result.results)
            currentCount += result.results.count
            totalCount = result.total
            page += 1
            footerState = .loading
            if currentCount == totalCount { footerState = .endOfResult }
            update(with: images)
        }
    }
    
    func fetchData(searchTerm: String, page: Int) {
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
    
    // MARK: State handlers
    // handles data in footer depending on state (text / activity indicator)
    enum FooterLabelText {
        case loading
        case endOfResult
        case blank
    }
    var footerState = FooterLabelText.blank
    
    // prevent api from triggering when a request is already in progress
    // will patiently wait for the current request to complete
    enum PrefetchState {
        case fetching
        case idle
    }
    var prefetchState: PrefetchState = .idle
    
    
    // MARK: - DiffableDataSource configuration
    private lazy var diffableDataSource: UICollectionViewDiffableDataSource<Int, Image> = {
        // cell config
        let dataSource = UICollectionViewDiffableDataSource<Int, Image>(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as! SearchCollectionViewCell
            cell.configure(label: self.images[indexPath.row].user.username, image: self.images[indexPath.row].urls.small)
            return cell
        }
        
        // footer config
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            switch kind {
            case UICollectionView.elementKindSectionFooter:
                guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sampleFooterIdentifier", for: indexPath) as? SearchCollectionReusableView
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
                
                // set data of text label in footer depending on state
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
    
    
    // MARK: - Collection view configuration
    private lazy var collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .estimated(44))
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize,
                                                                       elementKind: UICollectionView.elementKindSectionFooter,
                                                                         alignment: .bottom)
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionFooter]
        let layout = UICollectionViewCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.register(SearchCollectionViewCell.self,
                                forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        collectionView.register(SearchCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: "sampleFooterIdentifier")
        return collectionView
    }()
    
    // Let's user navigate to a new page with more information when a cell is clicked.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let view = mainStoryboard.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController
        let image = images[indexPath.row]
        view.configure(data: image)
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    // pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let input = searchInput,
           currentCount > 0,
           page > 1,
           // call API when user reaches the of the currently displayed images.
           indexPath.row == images.count - 1 {
            fetchData(searchTerm: input, page: page)
        }
    }
    
    
    //MARK: - Search bar configuration
    var searchController = UISearchController()

    // purge any existing data in the diff data source when performing a new search
    func purgeData() {
        images = []
        currentCount = 0
        totalCount = 0
        page = 1
    }
    
    // trigger search when search button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        purgeData()
        if let input = self.searchController.searchBar.text {
            title = "Searching for: \(input)"
            let inputConcat = input.replacingOccurrences(of: " ", with: "+")
            // call api w/ queries
            fetchData(searchTerm: inputConcat, page: page)
        }
        // dismiss search bar when a new search is triggered
        searchController.isActive = false
    }
    
    
    // MARK: - et al
    override func loadView() {
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = diffableDataSource
        collectionView.delegate = self
        searchController.searchBar.placeholder = "Search.."
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

