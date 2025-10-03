import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @State private var selectedSerial: Serial?
    @State private var showingDetail = false
    
    var body: some View {
        ZStack {
            // Background
            Color.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main Content
                TabView(selection: $appViewModel.selectedTab) {
                    HomeView()
                        .tag(TabSelection.home)
                    
                    SearchView()
                        .tag(TabSelection.search)
                    
                    FavoritesView()
                        .tag(TabSelection.favorites)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $appViewModel.selectedTab)
                    .background(Color.cardBackground)
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let serial = selectedSerial {
                SerialDetailView(serial: serial)
            }
        }
        .onAppear {
            setupApp()
        }
    }
    
    private func setupApp() {
        // Initialize app settings
        appViewModel.userPreferences.savePreferences()
    }
}

// MARK: - Favorites View
struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var selectedSerial: Serial?
    @State private var showingDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Content
                    if viewModel.favoriteSerials.isEmpty {
                        emptyFavoritesView
                    } else {
                        favoritesGridView
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
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Favorites")
                        .font(.largeTitle)
                        .foregroundColor(.textPrimary)
                    
                    Text("\(viewModel.favoriteSerials.count) saved items")
                        .font(.body)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    // Settings or sort action
                }) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primaryColor)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
    
    // MARK: - Empty Favorites View
    private var emptyFavoritesView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            EmptyStateView(
                title: "No Favorites Yet",
                message: "Start adding movies and series to your favorites by tapping the heart icon",
                icon: "heart"
            )
            
            Button("Browse Content") {
                // Switch to home tab
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.primaryColor)
            .cornerRadius(12)
            
            Spacer()
        }
    }
    
    // MARK: - Favorites Grid View
    private var favoritesGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(viewModel.favoriteSerials) { serial in
                    VStack(spacing: 8) {
                        SerialCard(serial: serial) {
                            selectedSerial = serial
                            showingDetail = true
                        }
                        
                        // Remove from favorites button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.removeFromFavorites(serial)
                            }
                        }) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100) // Space for tab bar
        }
    }
}

// MARK: - Content View Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

// MARK: - App Theme
struct AppTheme {
    static let primaryColor = Color(red: 0.2, green: 0.3, blue: 0.8)
    static let secondaryColor = Color(red: 0.9, green: 0.9, blue: 0.95)
    static let accentColor = Color(red: 1.0, green: 0.4, blue: 0.2)
    static let backgroundColor = Color(red: 0.05, green: 0.05, blue: 0.1)
    static let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.8)
}

// MARK: - Animation Extensions
extension View {
    func fadeIn(delay: Double = 0) -> some View {
        self.opacity(0)
            .animation(.easeInOut(duration: 0.6).delay(delay), value: true)
            .onAppear {
                withAnimation {
                    self.opacity(1)
                }
            }
    }
    
    func slideInFromBottom(delay: Double = 0) -> some View {
        self.offset(y: 50)
            .opacity(0)
            .animation(.easeOut(duration: 0.6).delay(delay), value: true)
            .onAppear {
                withAnimation {
                    self.offset(y: 0)
                    self.opacity(1)
                }
            }
    }
    
    func scaleIn(delay: Double = 0) -> some View {
        self.scaleEffect(0.8)
            .opacity(0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: true)
            .onAppear {
                withAnimation {
                    self.scaleEffect(1.0)
                    self.opacity(1)
                }
            }
    }
}

// MARK: - Haptic Feedback
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
    
    func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.primaryColor, Color.accentColor]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.textPrimary)
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryColor.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}