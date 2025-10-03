import Foundation
import Combine

// MARK: - Network Manager
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppConfig.requestTimeout
        config.timeoutIntervalForResource = AppConfig.requestTimeout
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic API Call
    private func performRequest<T: Codable>(
        endpoint: String,
        responseType: T.Type,
        retryCount: Int = 0
    ) -> AnyPublisher<T, NetworkError> {
        
        guard let url = URL(string: AppConfig.baseURL + endpoint) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if error is DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.networkError(error)
                }
            }
            .catch { error -> AnyPublisher<T, NetworkError> in
                if retryCount < AppConfig.maxRetries {
                    return self.performRequest(
                        endpoint: endpoint,
                        responseType: responseType,
                        retryCount: retryCount + 1
                    )
                    .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                    .eraseToAnyPublisher()
                } else {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Serial Endpoints
    func fetchLatestSerials() -> AnyPublisher<[Serial], NetworkError> {
        return performRequest(
            endpoint: "/api/serials/latest",
            responseType: [Serial].self
        )
    }
    
    func fetchOldestSerials() -> AnyPublisher<[Serial], NetworkError> {
        return performRequest(
            endpoint: "/api/serials/oldest",
            responseType: [Serial].self
        )
    }
    
    func fetchRandomSerials() -> AnyPublisher<[Serial], NetworkError> {
        return performRequest(
            endpoint: "/api/serials/random",
            responseType: [Serial].self
        )
    }
    
    func searchSerials(query: String) -> AnyPublisher<[Serial], NetworkError> {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return performRequest(
            endpoint: "/api/serials/search?query=\(encodedQuery)",
            responseType: [Serial].self
        )
    }
    
    // MARK: - Play Serial
    func playSerial(id: Int) -> AnyPublisher<PlayResponse, NetworkError> {
        guard let url = URL(string: AppConfig.baseURL + "/api/play") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["id": id]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            return Fail(error: NetworkError.networkError(error))
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: PlayResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if error is DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Async/Await Support
extension NetworkManager {
    @MainActor
    func fetchLatestSerialsAsync() async throws -> [Serial] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchLatestSerials()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { serials in
                        continuation.resume(returning: serials)
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    @MainActor
    func fetchOldestSerialsAsync() async throws -> [Serial] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchOldestSerials()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { serials in
                        continuation.resume(returning: serials)
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    @MainActor
    func fetchRandomSerialsAsync() async throws -> [Serial] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchRandomSerials()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { serials in
                        continuation.resume(returning: serials)
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    @MainActor
    func searchSerialsAsync(query: String) async throws -> [Serial] {
        return try await withCheckedThrowingContinuation { continuation in
            searchSerials(query: query)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { serials in
                        continuation.resume(returning: serials)
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    @MainActor
    func playSerialAsync(id: Int) async throws -> PlayResponse {
        return try await withCheckedThrowingContinuation { continuation in
            playSerial(id: id)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { response in
                        continuation.resume(returning: response)
                    }
                )
                .store(in: &cancellables)
        }
    }
}