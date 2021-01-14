import UIKit


class ViewController : UIViewController, UISearchBarDelegate, UICollectionViewDelegate {
    
    
    // API
    var dataManager = DataManager()
    // api data / trackers
    var images: [Result] = []
    var totalCount = 0
    var currentCount = 0
    var page = 1
    var searchInput: String?
    
    // sets the text of the footer textLabel depending on which case we specify in our collection supplementary view
    var footerState = StatusLabelText.blank
    enum StatusLabelText {
        case loading
        case endOfResult
        case blank
    }
    
    
    //MARK: Welcome message configuration
    
    
    
    
    
    
    
    
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
    
    
    
    
    
    //MARK: API methods & coonfig
    
    // prevent fetch from requesting data when a request is already in progress.
    var prefetchState: PrefetchState = .idle
    enum PrefetchState {
        case fetching
        case idle
    }
    
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
    
    // update the collection view cells / footer with our requested data
    private func update(with items: [Result]) {
        // compares new data with current data and updates cells/view if any changes were made.
        var snapshot = NSDiffableDataSourceSnapshot<Int, Result>()
        snapshot.appendSections([0])
        snapshot.appendItems(images, toSection: 0)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    // handle the data that we get from the fetchData method.
    private func responseHandler(result: Images) {
        if result.results.isEmpty {
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
    
    
    
    
    // MARK: Collection view configuration
    
    private lazy var collectionView: UICollectionView = {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                              heightDimension: .fractionalHeight(1.0))
//
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 5,
//                                                     leading: 5,
//                                                     bottom: 5,
//                                                     trailing: 5)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                               heightDimension: .fractionalHeight(0.25))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
//                                                       subitem: item,
//                                                       count: 2)
//        let section = NSCollectionLayoutSection(group: group)
//        let layout = UICollectionViewCompositionalLayout(section: section)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.footerReferenceSize = CGSize(width: 0, height: 60)
        
        
 
           
        
        
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.register(CollectionViewCell.self,
                                forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionView.register(CollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: "sampleFooterIdentifier")
        return collectionView
    }()
    
    // Let's user navigate to a new page with more information on the image clicked
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let view = mainStoryboard.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController
        let image = images[indexPath.row]
        view.configure(user: image.user.username,
                       image: image.urls.regular,
                       date: "created: \(image.created_at)",
                       description: image.description ?? "no description available")
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    // pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let input = searchInput,
           currentCount > 0,
           page > 1,
           indexPath.row == images.count - 1 {
            fetchData(searchTerm: input, page: page)
        }
    }
    
    
    
    
    //MARK: Search bar configuration
    var searchController = UISearchController()
    private func resetDataForNewSearch() {
        images = []
        currentCount = 0
        totalCount = 0
        page = 1
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resetDataForNewSearch()
        
        if let input = self.searchController.searchBar.text {
            title = "Searching for: \(input)"
            fetchData(searchTerm: input, page: page)
        }
        searchController.isActive = false
    }
    
    
    // MARK: viewdidload / appear
    
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
