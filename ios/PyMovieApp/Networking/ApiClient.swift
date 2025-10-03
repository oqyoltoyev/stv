import Foundation

enum ApiError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Int)
    case decodingFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .requestFailed(let code): return "Request failed with status code \(code)"
        case .decodingFailed: return "Failed to decode response"
        case .unknown: return "Unknown error"
        }
    }
}

final class ApiClient {
    static let shared = ApiClient()
    private let session: URLSession
    private let jsonDecoder: JSONDecoder

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 200 * 1024 * 1024)
        self.session = URLSession(configuration: config)
        self.jsonDecoder = JSONDecoder()
    }

    // MARK: - Public API

    func fetchLatest() async throws -> [Serial] { try await get(path: "/api/serials/latest") }
    func fetchOldest() async throws -> [Serial] { try await get(path: "/api/serials/oldest") }
    func fetchRandom() async throws -> [Serial] { try await get(path: "/api/serials/random") }
    func search(query: String) async throws -> [Serial] {
        try await get(path: "/api/serials/search", queryItems: [URLQueryItem(name: "query", value: query)])
    }
    func playLink(for id: Int) async throws -> PlayResponse {
        try await post(path: "/api/play", body: ["id": id])
    }

    // MARK: - Internal

    private func get<T: Decodable>(path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        guard var components = URLComponents(url: AppConfig.baseURL, resolvingAgainstBaseURL: false) else { throw ApiError.invalidURL }
        components.path = path
        if !queryItems.isEmpty { components.queryItems = queryItems }
        guard let url = components.url else { throw ApiError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ApiError.unknown }
        guard (200..<300).contains(http.statusCode) else { throw ApiError.requestFailed(http.statusCode) }
        do { return try jsonDecoder.decode(T.self, from: data) } catch { throw ApiError.decodingFailed }
    }

    private func post<T: Decodable>(path: String, body: [String: Any]) async throws -> T {
        guard var components = URLComponents(url: AppConfig.baseURL, resolvingAgainstBaseURL: false) else { throw ApiError.invalidURL }
        components.path = path
        guard let url = components.url else { throw ApiError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ApiError.unknown }
        guard (200..<300).contains(http.statusCode) else { throw ApiError.requestFailed(http.statusCode) }
        do { return try jsonDecoder.decode(T.self, from: data) } catch { throw ApiError.decodingFailed }
    }
}

