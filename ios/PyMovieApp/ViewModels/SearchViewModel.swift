import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = "" { didSet { scheduleSearch() } }
    @Published var results: [Serial] = []
    @Published var isSearching: Bool = false
    @Published var errorMessage: String? = nil

    private let debouncer = Debouncer(interval: 0.35)

    private func scheduleSearch() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            results = []
            errorMessage = nil
            isSearching = false
            debouncer.cancel()
            return
        }
        debouncer.schedule { [weak self] in
            Task { await self?.performSearch(q) }
        }
    }

    private func performSearch(_ q: String) async {
        isSearching = true
        errorMessage = nil
        do {
            let items = try await ApiClient.shared.search(query: q)
            self.results = items
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isSearching = false
    }
}

