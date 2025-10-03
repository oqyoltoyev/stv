import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedSerial: Serial?
    @State private var showingDetail = false
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Header
                    searchHeader
                    
                    // Content based on state
                    if viewModel.searchText.isEmpty {
                        emptySearchView
                    } else {
                        searchResultsView
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingDetail) {
            if let serial = selectedSerial {
                SerialDetailView(serial: serial)
            }
        }
    }
    
    // MARK: - Search Header
    private var searchHeader: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    // Back action or clear search
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }
                
                Text("Search")
                    .font(.largeTitle)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Search Bar
            SearchBar(text: $viewModel.searchText)
                .focused($isSearchFocused)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Empty Search View
    private var emptySearchView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            EmptyStateView(
                title: "Search Movies & Series",
                message: "Find your favorite content by typing in the search bar above",
                icon: "magnifyingglass"
            )
            
            // Popular Searches
            VStack(alignment: .leading, spacing: 16) {
                Text("Popular Searches")
                    .font(.title)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(popularSearches, id: \.self) { search in
                        Button(action: {
                            viewModel.searchText = search
                        }) {
                            Text(search)
                                .font(.body)
                                .foregroundColor(.textPrimary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primaryColor.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Search Results View
    private var searchResultsView: some View {
        VStack(spacing: 0) {
            // Results Header
            HStack {
                Text("\(viewModel.searchResults.count) results")
                    .font(.headline)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                if !viewModel.searchResults.isEmpty {
                    Button("Clear") {
                        viewModel.clearSearch()
                    }
                    .font(.body)
                    .foregroundColor(.primaryColor)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Results Content
            switch viewModel.loadingState {
            case .idle:
                EmptyView()
            case .loading:
                loadingView
            case .loaded:
                if viewModel.searchResults.isEmpty {
                    noResultsView
                } else {
                    resultsGridView
                }
            case .error(let error):
                errorView(error)
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            LoadingView()
            
            Text("Searching...")
                .font(.headline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 50)
    }
    
    // MARK: - No Results View
    private var noResultsView: some View {
        VStack(spacing: 20) {
            EmptyStateView(
                title: "No Results Found",
                message: "Try searching with different keywords or check your spelling",
                icon: "magnifyingglass"
            )
            
            Button("Clear Search") {
                viewModel.clearSearch()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.primaryColor)
            .cornerRadius(12)
        }
        .padding()
    }
    
    // MARK: - Results Grid View
    private var resultsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(viewModel.searchResults) { serial in
                    SerialCard(serial: serial) {
                        selectedSerial = serial
                        showingDetail = true
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100) // Space for tab bar
        }
    }
    
    // MARK: - Error View
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 20) {
            ErrorView(error: error) {
                // Retry search
                viewModel.performSearch(query: viewModel.searchText)
            }
        }
        .padding()
    }
    
    // MARK: - Popular Searches
    private let popularSearches = [
        "Action", "Comedy", "Drama", "Horror",
        "Sci-Fi", "Romance", "Thriller", "Documentary"
    ]
}

// MARK: - Search View Preview
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .preferredColorScheme(.dark)
    }
}

// MARK: - Search History
struct SearchHistoryView: View {
    @Binding var searchHistory: [String]
    let onSearchTap: (String) -> Void
    let onClearHistory: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Searches")
                    .font(.title)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if !searchHistory.isEmpty {
                    Button("Clear") {
                        onClearHistory()
                    }
                    .font(.body)
                    .foregroundColor(.primaryColor)
                }
            }
            .padding(.horizontal)
            
            if searchHistory.isEmpty {
                Text("No recent searches")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(searchHistory, id: \.self) { search in
                        Button(action: {
                            onSearchTap(search)
                        }) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.textSecondary)
                                
                                Text(search)
                                    .font(.body)
                                    .foregroundColor(.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "xmark")
                                    .foregroundColor(.textSecondary)
                                    .onTapGesture {
                                        searchHistory.removeAll { $0 == search }
                                    }
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Search Suggestions
struct SearchSuggestionsView: View {
    let suggestions: [String]
    let onSuggestionTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(suggestions, id: \.self) { suggestion in
                Button(action: {
                    onSuggestionTap(suggestion)
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.textSecondary)
                        
                        Text(suggestion)
                            .font(.body)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
    }
}