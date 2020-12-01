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
    
    var statusText = " "
    // sets the text of the footer textLabel depending on which case we specify in our collection supplementary view
    var statusLabelText = StatusLabelText.initial
    enum StatusLabelText {
        case initial
        case loading
        case endOfResult
        case blank
    }
    // view state for supplementary collection view
    var loadingData = false
    
    // requests data from our api based on the type of request we want.
    var fetchState = FetchState.request
    enum FetchState {
        case request
        case paginate
    }
    
     // MARK: diffable data source
    private lazy var diffableDataSource: UICollectionViewDiffableDataSource<Int, Result> = {
        let dataSource = UICollectionViewDiffableDataSource<Int, Result>(collectionView: collectionView) { collectionView, indexPath, item in
            // cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
            cell.configure(label: self.images[indexPath.row].user.username, image: self.images[indexPath.row].urls.small)
            return cell
        }
        
        // supplementary view ( footer )
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            switch kind {
            case UICollectionView.elementKindSectionFooter:
                guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sampleFooterIdentifier", for: indexPath) as? CollectionReusableView else {
                    fatalError("Header is not registered")
                }
                let text = self.statusText, loading = self.loadingData
                footerView.fill(with: text, loading: loading)
                return footerView
            default:
                fatalError("Element \(kind) not supported")
            }
        }
        return dataSource
    }()
    
      
     // MARK: Collection view setup
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.footerReferenceSize = CGSize(width: 0, height: 60)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionView.register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "sampleFooterIdentifier")
        return collectionView
    }()
    
    

    // update the collection view cells / footer with our requested data
    private func update(with items: [Result]) {
        // React.js DOM rendering(?).
        // compares new data with current data and updates cells/view if any changes were made.
        var snapshot = NSDiffableDataSourceSnapshot<Int, Result>()
        snapshot.appendSections([0])
        snapshot.appendItems(images, toSection: 0)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
        
        // update footer text / activity indicator
        if let footer = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0)) as? CollectionReusableView {
            switch statusLabelText {
            case .initial:
                statusText = "Search for something"
                loadingData = false
            case .loading:
                statusText = " "
                loadingData = true
            case .endOfResult:
                statusText = "Nothing here.."
                loadingData = false
            case .blank:
                statusText = " "
                loadingData = false
            }
            footer.fill(with: statusText, loading: loadingData)
        }
    }
    
    
    // performs API requests based on the type request we have specified.
    // Initial search requests always trigger the case .request.
    // Pagination (loading more data after our inital request) always trigger the case .paginate
    private func fetchData(searchTerm: String, page: Int) {
        self.prefetchState = .fetching
        self.searchInput = searchTerm
            switch fetchState {
            case .request:
                // simulate longer loading times for demo purposes (+ 1.5 second from the time it is invoked)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.dataManager.fetch(page: page, searchTerm: searchTerm) { images in
                        if images.results.count != 0 {
                            self.statusLabelText = .loading
                            self.images.append(contentsOf: images.results)
                            self.totalCount = images.total
                            self.currentCount = images.results.count
                            self.update(with: self.images)
                            self.page += 1
                            // simulate longer loading times for demo purposes (+ 2 second from the time it is invoked)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.prefetchState = .idle
                            }
                        }
                        if self.currentCount == self.totalCount || images.results.count == 0 {
                            self.statusLabelText = .endOfResult
                            self.update(with: images.results)
                            // simulate longer loading times for demo purposes (+ 2 second from the time it is invoked)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.prefetchState = .idle
                            }
                        }
                    }
                }
            case .paginate:
                // simulate longer loading times for demo purposes (+ 1.5 second from the time it is invoked)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.dataManager.fetch(page: page, searchTerm: searchTerm) { images in
                        if !images.results.isEmpty {
                            self.images.append(contentsOf: images.results)
                            self.currentCount += images.results.count
                            self.update(with: self.images)
                            self.page += 1
                            // simulate longer loading times for demo purposes (+ 2 second from the time it is invoked)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.prefetchState = .idle
                            }
                        }
                        if self.currentCount == self.totalCount {
                            self.statusLabelText = .endOfResult
                            self.update(with: self.images)
                            // simulate longer loading times for demo purposes (+ 2 second from the time it is invoked)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.prefetchState = .idle
                            }
                        }
                    }
                }
            }
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // update our footer with the "initial" view state
        self.statusLabelText = .initial
        self.update(with: images)
    }
    
    
    // Let's user navigate to a new page with more information on the image clicked
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let view = mainStoryboard.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController
        let image = self.images[indexPath.row]
        view.configure(user: image.user.username, image: image.urls.regular, date: "created: \(image.created_at)", description: image.description ?? "no description available")
        self.navigationController?.pushViewController(view, animated: true)
    }
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // When performing a new search we reset our data
        images = []
        statusLabelText = .loading
        fetchState = .request
        page = 1
        update(with: self.images)
        // request a new search for the first page
        // with our users input as the secondary query for our api
        if let input = searchController.searchBar.text {
            title = "Searching for: \(input)"
            fetchData(searchTerm: input, page: page)
        }
        searchController.isActive = false
    }
    
    
    // calls .paginate request when user scrolls close to the bottom of the view container.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard prefetchState == .idle else { return }
        self.statusLabelText = .loading
        let position = scrollView.contentOffset.y
        if position >= collectionView.contentSize.height - scrollView.frame.size.height {
            if let input = searchInput,
               prefetchState == .idle,
               currentCount > 1,
               page > 1,
               currentCount < totalCount {
                fetchState = .paginate
                fetchData(searchTerm: input, page: page)
            }
        }
    }
    
}


