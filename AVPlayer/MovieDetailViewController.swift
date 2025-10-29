import UIKit
import AVKit
import SafariServices // 유튜브 URL 재생을 위해 SafariServices 임포트

class MovieDetailViewController: UIViewController {

    // MARK: - Constants & Properties
    private let collapsedOverviewLines: Int = 4
    private let imageRatio: CGFloat = 1.5
    private var currentImageTask: URLSessionDataTask?

    let movie: Movie
    var isOverviewExpanded: Bool = false
    private let networkManager = NetworkManager() // NetworkManager 인스턴스

    // MARK: - Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray4
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .systemOrange
        label.text = "⭐️ \(String(format: "%.1f", movie.voteAverage)) / 10"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = collapsedOverviewLines
        label.text = movie.overview
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var toggleOverviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("더 보기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.addTarget(self, action: #selector(toggleOverview), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = movie.overview.count < 150
        return button
    }()

    private lazy var trailerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("▶️ 예고편 재생", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemRed.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(playTrailer), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization & Lifecycle
    
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = movie.title
        setupLayout()
        loadPosterImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let url = movie.fullPosterURL {
            ImageLoader.shared.cancelLoading(for: url)
        }
    }
    
    // MARK: - Setup UI & Layout (생략... 이전 코드와 동일)
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [posterImageView, ratingLabel, overviewLabel, toggleOverviewButton, trailerButton].forEach { contentView.addSubview($0) }
        
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
        
        let margin: CGFloat = 20
        let imageWidth = view.bounds.width * 0.4
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            posterImageView.widthAnchor.constraint(equalToConstant: imageWidth),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: imageRatio),
            ratingLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 10),
            ratingLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 15),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            trailerButton.leadingAnchor.constraint(equalTo: ratingLabel.leadingAnchor),
            trailerButton.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 20),
            trailerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            trailerButton.heightAnchor.constraint(equalToConstant: 44),
            overviewLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: margin),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            toggleOverviewButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 8),
            toggleOverviewButton.leadingAnchor.constraint(equalTo: overviewLabel.leadingAnchor),
            toggleOverviewButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin * 2)
        ])
    }
    
    // MARK: - Data & Actions
    
    private func loadPosterImage() {
        guard let url = movie.fullPosterURL else { return }
        
        currentImageTask = ImageLoader.shared.loadImage(from: url) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let image) = result {
                    self?.posterImageView.image = image
                }
            }
        }
    }
    
    @objc private func toggleOverview() {
        isOverviewExpanded.toggle()
        overviewLabel.numberOfLines = isOverviewExpanded ? 0 : collapsedOverviewLines
        let buttonTitle = isOverviewExpanded ? "접기" : "더 보기"
        toggleOverviewButton.setTitle(buttonTitle, for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func playTrailer() {
        
        // 예고편 정보 로딩 시작
        trailerButton.isEnabled = false // 중복 클릭 방지
        
        networkManager.fetchMovieTrailer(movieID: movie.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.trailerButton.isEnabled = true
                
                switch result {
                case .success(let trailer):
                    // 예고편 URL이 유효한지 확인
                    guard let url = trailer.youtubeURL else {
                        self.showAlert(message: "유효한 YouTube 예고편 URL을 찾을 수 없습니다.")
                        return
                    }
                    
                    // AVPlayer 대신 SFSafariViewController를 사용하여 YouTube 웹에서 재생
                    // AVPlayer는 특정 YouTube URL 포맷을 직접 지원하지 않기 때문에 Safari를 사용합니다.
                    let safariVC = SFSafariViewController(url: url)
                    self.present(safariVC, animated: true)

                case .failure(let error):
                    let errorMessage = error.localizedDescription
                    self.showAlert(message: "예고편 로드 실패: \(errorMessage)")
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
