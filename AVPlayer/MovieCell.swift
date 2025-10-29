import UIKit

/// 영화 정보를 표시하는 CollectionView 셀
class MovieCell: UICollectionViewCell {
    
    // MARK: - 프로퍼티
    
    /// 현재 진행 중인 이미지 다운로드 작업 (재사용 시 취소용)
    private var currentTask: URLSessionDataTask?
    
    // MARK: - UI 컴포넌트
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "포스터 없음"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 2
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - 초기화
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 생명주기
    
    /// 셀 재사용 시 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 진행 중인 이미지 다운로드 취소
        currentTask?.cancel()
        currentTask = nil
        
        // UI 초기화
        posterImageView.image = nil
        posterImageView.backgroundColor = .systemGray4
        placeholderLabel.isHidden = false
        titleLabel.text = nil
        overviewLabel.text = nil
    }
    
    // MARK: - UI 설정
    
    private func setupUI() {
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(overviewLabel)
        posterImageView.addSubview(placeholderLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 포스터 이미지 (상단, 전체 너비, 3:2 비율)
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5),
            
            // 플레이스홀더 레이블 (이미지 중앙)
            placeholderLabel.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),
            
            // 제목 레이블 (이미지 아래)
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            
            // 줄거리 레이블 (제목 아래)
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            overviewLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    // MARK: - 데이터 설정
    
    /// 영화 데이터로 셀 구성
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        
        loadPosterImage(from: movie.fullPosterURL)
    }
    
    // MARK: - 비공개 메서드
    
    /// 포스터 이미지 로드
    private func loadPosterImage(from url: URL?) {
        guard let url = url else {
            showPlaceholder()
            return
        }
        
        placeholderLabel.isHidden = true
        
        currentTask = ImageLoader.shared.loadImage(from: url) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleImageLoadResult(result)
            }
        }
    }
    
    /// 이미지 로드 결과 처리
    private func handleImageLoadResult(_ result: Result<UIImage, Error>) {
        switch result {
        case .success(let image):
            posterImageView.image = image
            placeholderLabel.isHidden = true
            
        case .failure:
            showPlaceholder()
        }
    }
    
    /// 플레이스홀더 표시
    private func showPlaceholder() {
        posterImageView.image = nil
        placeholderLabel.isHidden = false
    }
}
