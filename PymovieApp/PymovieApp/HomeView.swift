import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @State private var selectedSerial: Serial?
    @State private var showingDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        headerView
                        
                        // Content based on loading state
                        switch viewModel.loadingState {
                        case .idle, .loading:
                            loadingView
                        case .loaded:
                            contentView
                        case .error(let error):
                            errorView(error)
                        }
                    }
                }
                .refreshable {
                    viewModel.refreshData()
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
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pymovie")
                        .font(.largeTitle)
                        .foregroundColor(.textPrimary)
                    
                    Text("Discover amazing content")
                        .font(.body)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    // Profile or settings action
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.primaryColor)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 30) {
            LoadingView()
            
            Text("Loading amazing content...")
                .font(.headline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 30) {
            // Latest Serials Section
            if !viewModel.latestSerials.isEmpty {
                VStack(spacing: 16) {
                    SectionHeader(title: "Latest Releases") {
                        // See all action
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.latestSerials.prefix(10)) { serial in
                                SerialCard(serial: serial) {
                                    selectedSerial = serial
                                    showingDetail = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Oldest Serials Section
            if !viewModel.oldestSerials.isEmpty {
                VStack(spacing: 16) {
                    SectionHeader(title: "Classic Collection") {
                        // See all action
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.oldestSerials.prefix(10)) { serial in
                                SerialCard(serial: serial) {
                                    selectedSerial = serial
                                    showingDetail = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Random Serials Section
            if !viewModel.randomSerials.isEmpty {
                VStack(spacing: 16) {
                    SectionHeader(title: "Discover More") {
                        // See all action
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.randomSerials.prefix(10)) { serial in
                                SerialCard(serial: serial) {
                                    selectedSerial = serial
                                    showingDetail = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Bottom padding for tab bar
            Color.clear
                .frame(height: 100)
        }
    }
    
    // MARK: - Error View
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 20) {
            ErrorView(error: error) {
                viewModel.refreshData()
            }
        }
        .padding()
    }
}

// MARK: - Home View Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
    }
}

// MARK: - Featured Serial Card
struct FeaturedSerialCard: View {
    let serial: Serial
    let onTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            AsyncImage(url: URL(string: serial.poster)) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.textSecondary)
                    )
            }
            .frame(height: 200)
            .clipped()
            .cornerRadius(16)
            
            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(16)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(serial.title)
                    .font(.title)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(serial.episodes)
                    .font(.headline)
                    .foregroundColor(.textSecondary)
                
                PlayButton(action: onTap)
            }
            .padding()
        }
        .frame(height: 200)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Quick Actions
struct QuickActionsView: View {
    let onSearchTap: () -> Void
    let onFavoritesTap: () -> Void
    let onRandomTap: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            QuickActionButton(
                icon: "magnifyingglass",
                title: "Search",
                color: .primaryColor
            ) {
                onSearchTap()
            }
            
            QuickActionButton(
                icon: "heart.fill",
                title: "Favorites",
                color: .accentColor
            ) {
                onFavoritesTap()
            }
            
            QuickActionButton(
                icon: "shuffle",
                title: "Random",
                color: .secondaryColor
            ) {
                onRandomTap()
            }
        }
        .padding(.horizontal)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(color)
                    )
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}