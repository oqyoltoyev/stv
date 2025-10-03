import SwiftUI
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Serial] = []
    @Published var searchState: LoadingState = .idle
    @Published var recentSearches: [String] = []
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    private var searchCancellable: AnyCancellable?
    
    init() {
        loadRecentSearches()
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                if searchText.isEmpty {
                    self?.searchResults = []
                    self?.searchState = .idle
                } else {
                    self?.performSearch(query: searchText)
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            searchState = .idle
            return
        }
        
        searchState = .loading
        
        searchCancellable?.cancel()
        searchCancellable = networkService.searchSerials(query: query)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.searchState = .error(error.localizedDescription)
                        self?.searchResults = []
                    }
                },
                receiveValue: { [weak self] serials in
                    self?.searchResults = serials
                    self?.searchState = .loaded
                    
                    // Save to recent searches
                    if !serials.isEmpty {
                        self?.addToRecentSearches(query)
                    }
                }
            )
    }
    
    private func addToRecentSearches(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove if already exists
        recentSearches.removeAll { $0.lowercased() == trimmedQuery.lowercased() }
        
        // Add to beginning
        recentSearches.insert(trimmedQuery, at: 0)
        
        // Keep only last 10
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        
        saveRecentSearches()
    }
    
    private func loadRecentSearches() {
        if let data = UserDefaults.standard.data(forKey: "RecentSearches"),
           let searches = try? JSONDecoder().decode([String].self, from: data) {
            recentSearches = searches
        }
    }
    
    private func saveRecentSearches() {
        if let data = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(data, forKey: "RecentSearches")
        }
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        UserDefaults.standard.removeObject(forKey: "RecentSearches")
    }
    
    func selectRecentSearch(_ query: String) {
        searchText = query
    }
    
    func retrySearch() {
        if !searchText.isEmpty {
            performSearch(query: searchText)
        }
    }
}

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedSerial: Serial?
    @State private var showingDetail = false
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Content
                if viewModel.searchText.isEmpty {
                    recentSearchesView
                } else {
                    searchResultsView
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Qidiruv")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingDetail) {
            if let serial = selectedSerial {
                SerialDetailView(serial: serial)
            }
        }
    }
    
    private var searchBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("Serial yoki film qidiring...", text: $viewModel.searchText)
                        .focused($isSearchFocused)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(.body, design: .rounded))
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
                
                if isSearchFocused {
                    Button("Bekor qilish") {
                        viewModel.searchText = ""
                        isSearchFocused = false
                    }
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.blue)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
            
            Divider()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var recentSearchesView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if !viewModel.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Oxirgi qidiruvlar")
                                .font(.system(.headline, design: .rounded, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button("Tozalash") {
                                viewModel.clearRecentSearches()
                            }
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.recentSearches, id: \.self) { search in
                                Button(action: {
                                    viewModel.selectRecentSearch(search)
                                    isSearchFocused = true
                                }) {
                                    HStack {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 16))
                                        
                                        Text(search)
                                            .font(.system(.body, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.up.left")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 14))
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemBackground))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    EmptyStateView(
                        title: "Qidiruv boshlang",
                        message: "Sevimli serial yoki filmingizni qidiring",
                        systemImage: "magnifyingglass"
                    )
                    .padding(.top, 100)
                }
            }
            .padding(.vertical)
        }
    }
    
    private var searchResultsView: some View {
        Group {
            switch viewModel.searchState {
            case .idle:
                EmptyView()
                
            case .loading:
                VStack {
                    Spacer()
                    LoadingView()
                    Spacer()
                }
                
            case .loaded:
                if viewModel.searchResults.isEmpty {
                    VStack {
                        Spacer()
                        EmptyStateView(
                            title: "Hech narsa topilmadi",
                            message: "'\(viewModel.searchText)' uchun natija yo'q",
                            systemImage: "magnifyingglass"
                        )
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Results count
                            HStack {
                                Text("\(viewModel.searchResults.count) ta natija")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            // Results list
                            ForEach(viewModel.searchResults) { serial in
                                LargeSerialCardView(serial: serial) {
                                    selectedSerial = serial
                                    showingDetail = true
                                }
                                .padding(.horizontal)
                            }
                            
                            // Bottom spacing
                            Color.clear.frame(height: 20)
                        }
                    }
                }
                
            case .error(let message):
                VStack {
                    Spacer()
                    ErrorView(message: message) {
                        viewModel.retrySearch()
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SearchView()
}