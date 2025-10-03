import Foundation
import Combine

// MARK: - Home View Model
@MainActor
class HomeViewModel: ObservableObject {
    @Published var latestSerials: [Serial] = []
    @Published var oldestSerials: [Serial] = []
    @Published var randomSerials: [Serial] = []
    @Published var loadingState: LoadingState = .idle
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
    }
    
    func loadData() {
        loadingState = .loading
        errorMessage = nil
        
        Task {
            do {
                async let latest = networkManager.fetchLatestSerialsAsync()
                async let oldest = networkManager.fetchOldestSerialsAsync()
                async let random = networkManager.fetchRandomSerialsAsync()
                
                let (latestResult, oldestResult, randomResult) = try await (latest, oldest, random)
                
                self.latestSerials = latestResult
                self.oldestSerials = oldestResult
                self.randomSerials = randomResult
                self.loadingState = .loaded
            } catch {
                self.loadingState = .error(error)
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func refreshData() {
        loadData()
    }
}

// MARK: - Search View Model
@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Serial] = []
    @Published var loadingState: LoadingState = .idle
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    private var searchCancellable: AnyCancellable?
    
    init() {
        setupSearch()
    }
    
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.performSearch(query: searchText)
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            loadingState = .idle
            return
        }
        
        loadingState = .loading
        errorMessage = nil
        
        Task {
            do {
                let results = try await networkManager.searchSerialsAsync(query: query)
                self.searchResults = results
                self.loadingState = .loaded
            } catch {
                self.loadingState = .error(error)
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        loadingState = .idle
        errorMessage = nil
    }
}

// MARK: - Serial Detail View Model
@MainActor
class SerialDetailViewModel: ObservableObject {
    @Published var serial: Serial?
    @Published var loadingState: LoadingState = .idle
    @Published var errorMessage: String?
    @Published var playLink: String?
    @Published var isPlaying = false
    
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    func loadSerial(_ serial: Serial) {
        self.serial = serial
        loadingState = .loaded
    }
    
    func playSerial() {
        guard let serial = serial else { return }
        
        isPlaying = true
        loadingState = .loading
        
        Task {
            do {
                let response = try await networkManager.playSerialAsync(id: serial.id)
                self.playLink = response.link
                self.loadingState = .loaded
                self.isPlaying = false
                
                // Open Telegram link
                if let url = URL(string: response.link) {
                    await UIApplication.shared.open(url)
                }
            } catch {
                self.loadingState = .error(error)
                self.errorMessage = error.localizedDescription
                self.isPlaying = false
            }
        }
    }
}

// MARK: - Favorites View Model
@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoriteSerials: [Serial] = []
    @Published var loadingState: LoadingState = .idle
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favorite_serials"
    
    init() {
        loadFavorites()
    }
    
    private func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey),
           let serials = try? JSONDecoder().decode([Serial].self, from: data) {
            favoriteSerials = serials
        }
    }
    
    func addToFavorites(_ serial: Serial) {
        if !favoriteSerials.contains(where: { $0.id == serial.id }) {
            favoriteSerials.append(serial)
            saveFavorites()
        }
    }
    
    func removeFromFavorites(_ serial: Serial) {
        favoriteSerials.removeAll { $0.id == serial.id }
        saveFavorites()
    }
    
    func isFavorite(_ serial: Serial) -> Bool {
        return favoriteSerials.contains { $0.id == serial.id }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteSerials) {
            userDefaults.set(data, forKey: favoritesKey)
        }
    }
}

// MARK: - App View Model
@MainActor
class AppViewModel: ObservableObject {
    @Published var selectedTab: TabSelection = .home
    @Published var userPreferences = UserPreferences()
    @Published var isNetworkAvailable = true
    
    private let networkMonitor = NetworkMonitor()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: \.isNetworkAvailable, on: self)
            .store(in: &cancellables)
    }
}

// MARK: - Network Monitor
class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    
    init() {
        // Simple network monitoring - in a real app, you'd use Network framework
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkNetworkStatus()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func checkNetworkStatus() {
        // This is a simplified check - in production, use proper network monitoring
        isConnected = true
    }
}