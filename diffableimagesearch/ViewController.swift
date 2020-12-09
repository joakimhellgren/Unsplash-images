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
    var footerState = StatusLabelText.initial
    enum StatusLabelText {
        case initial
        case loading
        case endOfResult
        case blank
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
                guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                       withReuseIdentifier: "sampleFooterIdentifier",
                                                                                       for: indexPath) as? CollectionReusableView
                else {
                    print("error implementing footerView")
                    return UICollectionReusableView()
                }
                var loading: Bool {
                    switch self.footerState {
                    case .initial:
                        return false
                    case .loading:
                        return true
                    case .endOfResult:
                        return false
                    case .blank:
                        return false
                    }
                }
                var text: String {
                    switch self.footerState {
                    case .initial:
                        return "Search for something"
                    case .loading:
                        return " "
                    case .endOfResult:
                        return "Nothing here."
                    case .blank:
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
     // MARK: Collection view setup
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.footerReferenceSize = CGSize(width: 0, height: 60)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionView.register(CollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: "sampleFooterIdentifier")
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
    }
    // performs API requests
    private func fetchData(searchTerm: String, page: Int) {
        prefetchState = .fetching
        searchInput = searchTerm
        dataManager.fetch(page: page, searchTerm: searchTerm) { images in
            self.responseHandler(result: images)
        }
    }
    // handle response
    private func responseHandler(result: Images) {
        if result.results.isEmpty {
            footerState = .endOfResult
        } else {
            images.append(contentsOf: result.results)
            currentCount += result.results.count
            totalCount = result.total
            page += 1
            footerState = .loading
            if currentCount == totalCount { footerState = .endOfResult }
        }
        update(with: self.images)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.prefetchState = .idle
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
        title = "Search ⬇️"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    // Let's user navigate to a new page with more information on the image clicked
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let view = mainStoryboard.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController
        let image = images[indexPath.row]
        view.configure(user: image.user.username, image: image.urls.regular, date: "created: \(image.created_at)", description: image.description ?? "no description available")
        self.navigationController?.pushViewController(view, animated: true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // When performing a new search we reset our data
        images = []
        currentCount = 0
        totalCount = 0
        page = 1
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
        let position = scrollView.contentOffset.y
        if position >= collectionView.contentSize.height - scrollView.frame.size.height {
            if let input = searchInput, currentCount > 0, page > 1 {
                fetchData(searchTerm: input, page: page)
            }
        }
    }
}
