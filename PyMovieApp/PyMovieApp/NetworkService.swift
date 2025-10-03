import Foundation
import Combine

class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    // Change this to your backend URL
    private let baseURL = "http://localhost:5001"
    
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Generic Request Method
    private func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil
    ) -> AnyPublisher<T, APIError> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: APIError(message: "Invalid URL"))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return APIError(message: "Ma'lumotlarni o'qishda xato")
                } else {
                    return APIError(message: "Tarmoq xatosi: \(error.localizedDescription)")
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch Latest Serials
    func fetchLatestSerials() -> AnyPublisher<[Serial], APIError> {
        return request(endpoint: "/api/serials/latest")
    }
    
    // MARK: - Fetch Oldest Serials
    func fetchOldestSerials() -> AnyPublisher<[Serial], APIError> {
        return request(endpoint: "/api/serials/oldest")
    }
    
    // MARK: - Fetch Random Serials
    func fetchRandomSerials() -> AnyPublisher<[Serial], APIError> {
        return request(endpoint: "/api/serials/random")
    }
    
    // MARK: - Search Serials
    func searchSerials(query: String) -> AnyPublisher<[Serial], APIError> {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return request(endpoint: "/api/serials/search?query=\(encodedQuery)")
    }
    
    // MARK: - Play Serial
    func playSerial(id: Int) -> AnyPublisher<PlayResponse, APIError> {
        let playRequest = PlayRequest(id: id)
        
        guard let body = try? JSONEncoder().encode(playRequest) else {
            return Fail(error: APIError(message: "So'rovni kodlashda xato"))
                .eraseToAnyPublisher()
        }
        
        return request(endpoint: "/api/play", method: .POST, body: body)
    }
    
    // MARK: - Fetch Serials by Type
    func fetchSerials(type: SectionType) -> AnyPublisher<[Serial], APIError> {
        switch type {
        case .latest:
            return fetchLatestSerials()
        case .oldest:
            return fetchOldestSerials()
        case .random:
            return fetchRandomSerials()
        }
    }
}

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}