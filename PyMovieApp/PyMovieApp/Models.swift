import Foundation

// MARK: - Serial Model
struct Serial: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let episodes: String
    let poster: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Serial, rhs: Serial) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Play Response Model
struct PlayResponse: Codable {
    let link: String
}

// MARK: - Play Request Model
struct PlayRequest: Codable {
    let id: Int
}

// MARK: - API Error Model
struct APIError: Error, LocalizedError {
    let message: String
    
    var errorDescription: String? {
        return message
    }
}

// MARK: - Loading State
enum LoadingState {
    case idle
    case loading
    case loaded
    case error(String)
}

// MARK: - Section Type
enum SectionType: String, CaseIterable {
    case latest = "Yangi"
    case oldest = "Eski"
    case random = "Tasodifiy"
    
    var endpoint: String {
        switch self {
        case .latest:
            return "/api/serials/latest"
        case .oldest:
            return "/api/serials/oldest"
        case .random:
            return "/api/serials/random"
        }
    }
    
    var icon: String {
        switch self {
        case .latest:
            return "clock.fill"
        case .oldest:
            return "calendar"
        case .random:
            return "shuffle"
        }
    }
}