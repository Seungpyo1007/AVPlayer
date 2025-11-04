import UIKit
import AVKit
import YouTubeKit

/// 영화 상세 정보를 표시하는 화면
class MovieDetailViewController: UIViewController {

    // MARK: - 상수
    
    private enum Layout {
        static let collapsedOverviewLines = 4
        static let posterRatio: CGFloat = 1.5
        static let margin: CGFloat = 20
        static let posterWidthRatio: CGFloat = 0.4
        static let overviewMinLength = 150
    }
    
    // MARK: - 프로퍼티
    
    private let movie: Movie
    private var isOverviewExpanded = false
    private var currentImageTask: URLSessionDataTask?
    private let networkManager = NetworkManager()
    
    // MARK: - UI 컴포넌트
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .systemOrange
        label.text = "⭐️ \(String(format: "%.1f", self.movie.voteAverage)) / 10"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.numberOfLines = Layout.collapsedOverviewLines
        label.text = self.movie.overview
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var toggleOverviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("더 보기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.addTarget(self, action: #selector(toggleOverview), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = self.movie.overview.count < Layout.overviewMinLength
        return button
    }()

    private lazy var trailerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("예고편 재생", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemRed.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(playTrailer), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - 초기화
    
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 생명주기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPosterImage()
        
        // Large Title 비활성화 (부드러운 전환 애니메이션)
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelImageLoading()
    }
    
    // MARK: - UI 설정
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = movie.title
        
        setupViewHierarchy()
        setupConstraints()
    }
    
    private func setupViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(toggleOverviewButton)
        contentView.addSubview(trailerButton)
    }
    
    private func setupConstraints() {
        setupScrollViewConstraints()
        setupContentConstraints()
    }
    
    private func setupScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    private func setupContentConstraints() {
        let posterWidth = view.bounds.width * Layout.posterWidthRatio
        
        NSLayoutConstraint.activate([
            // 포스터 이미지 (좌측 상단)
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.margin),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.margin),
            posterImageView.widthAnchor.constraint(equalToConstant: posterWidth),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: Layout.posterRatio),
            
            // 평점 레이블 (포스터 우측 상단)
            ratingLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 10),
            ratingLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 15),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.margin),
            
            // 예고편 버튼 (평점 아래)
            trailerButton.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 20),
            trailerButton.leadingAnchor.constraint(equalTo: ratingLabel.leadingAnchor),
            trailerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.margin),
            trailerButton.heightAnchor.constraint(equalToConstant: 44),
            
            // 줄거리 레이블 (포스터 하단)
            overviewLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: Layout.margin),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.margin),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.margin),
            
            // 더보기 버튼 (줄거리 하단)
            toggleOverviewButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 8),
            toggleOverviewButton.leadingAnchor.constraint(equalTo: overviewLabel.leadingAnchor),
            toggleOverviewButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.margin * 2)
        ])
    }
    
    // MARK: - 이미지 로딩
    
    /// 포스터 이미지 로드
    private func loadPosterImage() {
        guard let url = movie.fullPosterURL else { return }
        currentImageTask = ImageLoader.shared.loadImage(from: url) { [weak self] result in
            self?.handleImageLoadResult(result)
        }
    }
    
    /// 이미지 로드 결과 처리
    private func handleImageLoadResult(_ result: Result<UIImage, Error>) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let image):
                self?.posterImageView.image = image
            case .failure:
                break
            }
        }
    }
    
    /// 이미지 로딩 취소
    private func cancelImageLoading() {
        if let url = movie.fullPosterURL {
            ImageLoader.shared.cancelLoading(for: url)
        }
    }
    
    // MARK: - 액션

    /// 줄거리 펼치기/접기
    @objc private func toggleOverview() {
        isOverviewExpanded.toggle()
        overviewLabel.numberOfLines = isOverviewExpanded ? 0 : Layout.collapsedOverviewLines
        toggleOverviewButton.setTitle(isOverviewExpanded ? "접기" : "더 보기", for: .normal)
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }

    /// 예고편 재생
    @objc private func playTrailer() {
        trailerButton.isEnabled = false
        networkManager.fetchMovieTrailer(movieID: movie.id) { [weak self] result in
            self?.handleTrailerFetchResult(result)
        }
    }

    // MARK: - 예고편 처리

    /// 예고편 가져오기 결과 처리
    private func handleTrailerFetchResult(_ result: Result<Trailer, NetworkManager.NetworkError>) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.trailerButton.isEnabled = true
            switch result {
            case .success(let trailer):
                self.openTrailer(trailer)
            case .failure(let error):
                self.showAlert(message: "예고편 로드 실패: \(error.localizedDescription)")
            }
        }
    }

    /// 예고편 열기 (AVPlayer 사용)
    private func openTrailer(_ trailer: Trailer) {
        guard let youtubeURL = trailer.youtubeURL else {
            showAlert(message: "유효한 YouTube 예고편을 찾을 수 없습니다.")
            return
        }
        resolveYouTubeStreamURL(from: youtubeURL) { [weak self] result in
            switch result {
            case .success(let streamURL):
                self?.presentPlayer(with: streamURL)
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(message: "예고편 재생 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    private func presentPlayer(with url: URL) {
        DispatchQueue.main.async { [weak self] in
            let player = AVPlayer(url: url)
            let playerVC = AVPlayerViewController()
            playerVC.player = player
            playerVC.modalPresentationStyle = .fullScreen
            self?.present(playerVC, animated: true) {
                player.play()
            }
        }
    }

    private struct NoPlayableStreamError: LocalizedError {
        var errorDescription: String? { "재생 가능한 스트림을 찾을 수 없습니다." }
    }

    /// YouTube 페이지 URL에서 실제 미디어 스트림 URL을 YouTubeKit으로 해석합니다.
    /// - Note: YouTubeKit은 Swift Concurrency(Async/Await)를 사용합니다. 내부에서 Task로 래핑하여 콜백으로 전달합니다.
    private func resolveYouTubeStreamURL(from youtubeURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        Task {
            do {
                let video = YouTube(url: youtubeURL)
                let streams = try await video.streams
                if let best = streams.filterVideoAndAudio().filter({ $0.isNativelyPlayable }).highestResolutionStream() {
                    completion(.success(best.url))
                    return
                }
                if let fallback = streams.filterVideoAndAudio().highestResolutionStream() {
                    completion(.success(fallback.url))
                    return
                }
                if let audioOnly = streams.filterAudioOnly().highestAudioBitrateStream() {
                    completion(.success(audioOnly.url))
                    return
                }
                completion(.failure(NoPlayableStreamError()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// 알림 표시
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

