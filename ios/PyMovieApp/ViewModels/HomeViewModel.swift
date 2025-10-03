import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var latest: [Serial] = []
    @Published var oldest: [Serial] = []
    @Published var randoms: [Serial] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func load(force: Bool = false) async {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        do {
            async let l: [Serial] = ApiClient.shared.fetchLatest()
            async let o: [Serial] = ApiClient.shared.fetchOldest()
            async let r: [Serial] = ApiClient.shared.fetchRandom()
            let (latest, oldest, randoms) = try await (l, o, r)
            self.latest = latest
            self.oldest = oldest
            self.randoms = randoms
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

