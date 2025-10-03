import SwiftUI

struct SerialDetailView: View {
    let serial: Serial
    @StateObject private var viewModel = SerialDetailViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero Section
                        heroSection
                        
                        // Content Section
                        contentSection
                        
                        // Episodes Section
                        episodesSection
                        
                        // Related Content
                        relatedSection
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadSerial(serial)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [serial.title, serial.poster])
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            AsyncImage(url: URL(string: serial.poster)) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.cardBackground)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.textSecondary)
                    )
            }
            .frame(height: 300)
            .clipped()
            
            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                // Back Button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            if favoritesViewModel.isFavorite(serial) {
                                favoritesViewModel.removeFromFavorites(serial)
                            } else {
                                favoritesViewModel.addToFavorites(serial)
                            }
                        }) {
                            Image(systemName: favoritesViewModel.isFavorite(serial) ? "heart.fill" : "heart")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(favoritesViewModel.isFavorite(serial) ? .accentColor : .white)
                                .frame(width: 36, height: 36)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                // Title and Info
                VStack(alignment: .leading, spacing: 12) {
                    Text(serial.title)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .lineLimit(3)
                    
                    HStack(spacing: 16) {
                        Text(serial.episodes)
                            .font(.headline)
                            .foregroundColor(.textSecondary)
                        
                        Text("HD")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primaryColor)
                            .cornerRadius(4)
                    }
                    
                    // Play Button
                    HStack(spacing: 16) {
                        PlayButton(action: {
                            viewModel.playSerial()
                        })
                        .disabled(viewModel.isPlaying)
                        
                        if viewModel.isPlaying {
                            LoadingView()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("About")
                    .font(.title)
                    .foregroundColor(.textPrimary)
                
                Text("Discover amazing content with this \(serial.episodes.lowercased()). Experience high-quality streaming and enjoy your favorite shows and movies.")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)
            }
            .padding(.horizontal)
            
            // Info Cards
            HStack(spacing: 16) {
                InfoCard(
                    icon: "tv",
                    title: "Type",
                    value: serial.episodes.contains("Episode") ? "TV Series" : "Movie"
                )
                
                InfoCard(
                    icon: "star.fill",
                    title: "Rating",
                    value: "4.5"
                )
                
                InfoCard(
                    icon: "calendar",
                    title: "Year",
                    value: "2024"
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Episodes Section
    private var episodesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Episodes")
                .font(.title)
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
            
            if serial.episodes.contains("Episode") {
                // Generate sample episodes
                LazyVStack(spacing: 12) {
                    ForEach(1...10, id: \.self) { episode in
                        EpisodeRow(
                            episodeNumber: episode,
                            title: "Episode \(episode)",
                            duration: "45 min",
                            isWatched: episode <= 3
                        ) {
                            // Play episode action
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                // Movie - show single play option
                VStack(spacing: 16) {
                    Text("This is a movie")
                        .font(.headline)
                        .foregroundColor(.textSecondary)
                        .padding()
                    
                    PlayButton(action: {
                        viewModel.playSerial()
                    })
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Related Section
    private var relatedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("More Like This")
                .font(.title)
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(1...5, id: \.self) { index in
                        RelatedSerialCard(
                            title: "Related Movie \(index)",
                            poster: serial.poster
                        ) {
                            // Navigate to related serial
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 100) // Space for tab bar
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.primaryColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Episode Row
struct EpisodeRow: View {
    let episodeNumber: Int
    let title: String
    let duration: String
    let isWatched: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Episode Number
            Text("\(episodeNumber)")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(isWatched ? Color.primaryColor : Color.cardBackground)
                )
            
            // Episode Info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text(duration)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Play Button
            Button(action: onTap) {
                Image(systemName: "play.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.primaryColor)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Related Serial Card
struct RelatedSerialCard: View {
    let title: String
    let poster: String
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: poster)) { image in
                image
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardBackground)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(.textSecondary)
                    )
            }
            .frame(width: 100, height: 150)
            .clipped()
            .cornerRadius(8)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
                .frame(width: 100, alignment: .leading)
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Serial Detail View Preview
struct SerialDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SerialDetailView(serial: Serial(
            id: 1,
            title: "Sample Movie",
            episodes: "Movie",
            poster: "https://example.com/poster.jpg"
        ))
        .preferredColorScheme(.dark)
    }
}