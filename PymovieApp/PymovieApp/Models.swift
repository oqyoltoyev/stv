import Foundation

// MARK: - Serial Model
struct Serial: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let episodes: String
    let poster: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, episodes, poster
    }
}

// MARK: - API Response Models
struct PlayResponse: Codable {
    let link: String
}

// MARK: - Search Response
struct SearchResponse: Codable {
    let results: [Serial]
}

// MARK: - Error Types
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Loading States
enum LoadingState {
    case idle
    case loading
    case loaded
    case error(Error)
}

// MARK: - Tab Selection
enum TabSelection: String, CaseIterable {
    case home = "Home"
    case search = "Search"
    case favorites = "Favorites"
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .search:
            return "magnifyingglass"
        case .favorites:
            return "heart.fill"
        }
    }
}

// MARK: - Serial Category
enum SerialCategory: String, CaseIterable {
    case latest = "Latest"
    case oldest = "Oldest"
    case random = "Random"
    
    var apiEndpoint: String {
        switch self {
        case .latest:
            return "/api/serials/latest"
        case .oldest:
            return "/api/serials/oldest"
        case .random:
            return "/api/serials/random"
        }
    }
}

// MARK: - App Configuration
struct AppConfig {
    static let baseURL = "http://localhost:5001" // Change to your backend URL
    static let apiVersion = "v1"
    static let maxRetries = 3
    static let requestTimeout: TimeInterval = 30
}

// MARK: - User Preferences
class UserPreferences: ObservableObject {
    @Published var selectedLanguage: String = "en"
    @Published var darkModeEnabled: Bool = false
    @Published var autoPlayEnabled: Bool = true
    @Published var qualityPreference: String = "high"
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadPreferences()
    }
    
    private func loadPreferences() {
        selectedLanguage = userDefaults.string(forKey: "selectedLanguage") ?? "en"
        darkModeEnabled = userDefaults.bool(forKey: "darkModeEnabled")
        autoPlayEnabled = userDefaults.bool(forKey: "autoPlayEnabled")
        qualityPreference = userDefaults.string(forKey: "qualityPreference") ?? "high"
    }
    
    func savePreferences() {
        userDefaults.set(selectedLanguage, forKey: "selectedLanguage")
        userDefaults.set(darkModeEnabled, forKey: "darkModeEnabled")
        userDefaults.set(autoPlayEnabled, forKey: "autoPlayEnabled")
        userDefaults.set(qualityPreference, forKey: "qualityPreference")
    }
}