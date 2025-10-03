import Foundation

struct Serial: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let episodes: String
    let poster: URL?

    var isMovie: Bool {
        episodes.lowercased().contains("movie") || episodes.lowercased().contains("film")
    }
}

struct PlayResponse: Codable { let link: URL }

