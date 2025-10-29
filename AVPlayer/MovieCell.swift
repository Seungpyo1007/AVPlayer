import UIKit

class MovieCell: UICollectionViewCell {
    
    // MARK: - Properties
    private var currentTask: URLSessionDataTask?
    
    // MARK: - Components
    
    let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray4
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Poster"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization & Reuse
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        currentTask = nil
        posterImageView.image = nil
        placeholderLabel.isHidden = false
        posterImageView.backgroundColor = .systemGray4
        titleLabel.text = nil
        overviewLabel.text = nil
    }
    
    // MARK: - Setup UI & Layout
    
    private func setupViews() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(overviewLabel)
        posterImageView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            overviewLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    // MARK: - Data Binding
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        
        if let url = movie.fullPosterURL {
            placeholderLabel.isHidden = true
            
            currentTask = ImageLoader.shared.loadImage(from: url) { [weak self] result in
                DispatchQueue.main.async {
                    if case .success(let image) = result {
                        self?.posterImageView.image = image
                    } else if case .failure = result {
                        self?.placeholderLabel.isHidden = false
                    }
                }
            }
        } else {
            posterImageView.image = nil
            placeholderLabel.isHidden = false
        }
    }
}
