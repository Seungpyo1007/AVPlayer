import Foundation

class NetworkManager {
    

    private let bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2NDk0ZTI3ZmVhOGFjOTJhM2IyZDQ2YjlkZjI4OTc2MiIsIm5iZiI6MTc2MTcwMDE3Mi45ODUsInN1YiI6IjY5MDE2OTRjNTJiOWMwMDdmYmM0NjA0YiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.EEEH1P8JcEUazWnkc4jHSz9PmtFmuLj-RZ4sq-BCAKY"
    private let baseURL = "https://api.themoviedb.org/3"
    
    enum NetworkError: Error {
        case invalidURL
        case noData
        case decodingFailed(Error)
        case apiError(String)
        case httpError(Int)
        
        var localizedDescription: String {
            switch self {
            case .invalidURL: return "유효하지 않은 URL입니다."
            case .noData: return "데이터를 수신하지 못했습니다."
            case .decodingFailed(let error): return "데이터 디코딩 실패: \(error.localizedDescription)"
            case .apiError(let message): return "API 오류: \(message)"
            case .httpError(let code):
                if code == 401 { return "인증 오류 (401). Bearer Token을 확인하세요." }
                return "HTTP 오류 코드: \(code)"
            }
        }
    }
    
    // V4 인증 헤더를 포함한 URLRequest를 생성합니다.
    private func createRequest(for urlString: String) -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(bearerToken)" // Bearer Token 적용
        ]
        return request
    }
    
    // MARK: - API Methods (영화 Fetching)
    
    func fetchPopularMovies(page: Int, completion: @escaping (Result<MovieResponse, NetworkError>) -> Void) {
        let urlString = "\(baseURL)/movie/popular?page=\(page)&language=ko-KR"
        guard let request = createRequest(for: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        performMovieTask(with: request, completion: completion)
    }

    func searchMovies(query: String, page: Int, completion: @escaping (Result<MovieResponse, NetworkError>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(.invalidURL))
            return
        }
        let urlString = "\(baseURL)/search/movie?query=\(encodedQuery)&page=\(page)&language=ko-KR"
        guard let request = createRequest(for: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        performMovieTask(with: request, completion: completion)
    }
    
    // 공통 URLSession Task 실행 로직 (MovieResponse용)
    private func performMovieTask(with request: URLRequest, completion: @escaping (Result<MovieResponse, NetworkError>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                if (error as NSError).code != NSURLErrorCancelled {
                    completion(.failure(.apiError(error.localizedDescription)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noData))
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                completion(.success(movieResponse))
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }
        
        task.resume()
    }
    
    // MARK: - API Methods (트레일러 Fetching)

    func fetchMovieTrailer(movieID: Int, completion: @escaping (Result<Trailer, NetworkError>) -> Void) {
        
        let urlString = "\(baseURL)/movie/\(movieID)/videos?language=ko-KR"
        
        guard let request = createRequest(for: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                if (error as NSError).code != NSURLErrorCancelled {
                    completion(.failure(.apiError(error.localizedDescription)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode), let data = data else {
                completion(.failure(.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let trailerResponse = try decoder.decode(TrailerResponse.self, from: data)
                
                // 타입이 "Trailer" 또는 "Teaser"이고 사이트가 "YouTube"인 첫 번째 결과를 찾습니다.
                if let trailer = trailerResponse.results.first(where: { ($0.type == "Trailer" || $0.type == "Teaser") && $0.site == "YouTube" }) {
                    completion(.success(trailer))
                } else {
                    completion(.failure(.noData))
                }
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }
        
        task.resume()
    }
}
