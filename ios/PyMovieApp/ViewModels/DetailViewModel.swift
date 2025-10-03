import Foundation

@MainActor
final class DetailViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var playURL: URL? = nil

    func requestPlay(for id: Int) async {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        do {
            let res = try await ApiClient.shared.playLink(for: id)
            self.playURL = res.link
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

