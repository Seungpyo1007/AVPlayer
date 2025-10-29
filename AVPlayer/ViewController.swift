import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.register(MovieCell.self, forCellWithReuseIdentifier: "MovieCell")
        return cv
    }()
    
    // MARK: - Data Properties
    
    private var movies: [Movie] = []
    private var currentPage = 1
    private var totalPages = 1
    private var currentSearchQuery: String?
    
    private let networkManager = NetworkManager()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPopularMovies()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "인기 영화 랭킹"
        
        setupCollectionView()
        setupSearchBar()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "검색어를 입력하세요"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: - Data Loading
    
    /// 초기 인기 영화 로드
    private func loadPopularMovies() {
        fetchMovies(query: nil, page: 1)
    }
    
    /// 영화 데이터 가져오기 (검색 또는 인기 영화)
    private func fetchMovies(query: String?, page: Int) {
        // 검색어가 있으면 검색, 없으면 인기 영화
        if let searchQuery = query, !searchQuery.isEmpty {
            networkManager.searchMovies(query: searchQuery, page: page) { [weak self] result in
                self?.handleFetchResult(result, page: page, query: searchQuery)
            }
        } else {
            networkManager.fetchPopularMovies(page: page) { [weak self] result in
                self?.handleFetchResult(result, page: page, query: nil)
            }
        }
    }
    
    /// 네트워크 응답 처리
    private func handleFetchResult(_ result: Result<MovieResponse, NetworkManager.NetworkError>,
                                   page: Int,
                                   query: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                // 첫 페이지면 새로 시작, 아니면 기존 데이터에 추가
                if page == 1 {
                    self.movies = response.results
                } else {
                    self.movies.append(contentsOf: response.results)
                }
                
                self.currentPage = response.page
                self.totalPages = response.totalPages
                self.currentSearchQuery = query
                
                // 화면 제목 업데이트
                self.title = query == nil ? "인기 영화 랭킹" : "검색 결과"
                
                self.collectionView.reloadData()
                
            case .failure(let error):
                print("영화 로드 실패: \(error.localizedDescription)")
                // TODO: 사용자에게 에러 알림 표시
            }
        }
    }
    
    /// 다음 페이지 로드 (무한 스크롤)
    private func loadNextPageIfNeeded() {
        guard currentPage < totalPages else { return }
        fetchMovies(query: currentSearchQuery, page: currentPage + 1)
    }
}

// MARK: - UISearchResultsUpdating

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else { return }
        
        // 0.5초 디바운싱 (타이핑 중 과도한 API 호출 방지)
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(performSearch),
            object: searchText
        )
        perform(#selector(performSearch), with: searchText, afterDelay: 0.5)
    }
    
    @objc private func performSearch(_ query: String) {
        fetchMovies(query: query, page: 1)
    }
}

// MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 검색 취소 시 인기 영화로 복귀
        currentSearchQuery = nil
        movies = []
        collectionView.reloadData()
        loadPopularMovies()
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MovieCell",
            for: indexPath
        ) as? MovieCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: movies[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let spacing: CGFloat = 10
        let totalHorizontalSpacing = (padding * 2) + spacing
        
        // 한 줄에 2개씩 배치
        let itemWidth = (collectionView.bounds.width - totalHorizontalSpacing) / 2
        let itemHeight = itemWidth * 1.5 + 50  // 포스터 비율 + 텍스트 영역
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    
    /// 무한 스크롤: 마지막 셀 표시 시 다음 페이지 로드
    func collectionView(_ collectionView: UICollectionView,
                       willDisplay cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath) {
        if indexPath.item == movies.count - 1 {
            loadNextPageIfNeeded()
        }
    }
    
    /// 영화 선택 시 상세 화면으로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let selectedMovie = movies[indexPath.item]
        let detailVC = MovieDetailViewController(movie: selectedMovie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
