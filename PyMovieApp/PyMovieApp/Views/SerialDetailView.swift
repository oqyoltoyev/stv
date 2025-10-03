import SwiftUI
import Combine

class SerialDetailViewModel: ObservableObject {
    @Published var playState: LoadingState = .idle
    @Published var playLink: String?
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func playSerial(_ serial: Serial) {
        playState = .loading
        
        networkService.playSerial(id: serial.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.playState = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.playLink = response.link
                    self?.playState = .loaded
                    
                    // Open Telegram link
                    if let url = URL(string: response.link) {
                        UIApplication.shared.open(url)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func retryPlay(_ serial: Serial) {
        playSerial(serial)
    }
}

struct SerialDetailView: View {
    let serial: Serial
    @StateObject private var viewModel = SerialDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection
                    
                    // Content Section
                    contentSection
                    
                    // Action Buttons
                    actionButtons
                    
                    // Bottom spacing
                    Color.clear.frame(height: 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Yopish") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [serial.title, serial.poster])
        }
    }
    
    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Background Image
            AsyncImage(url: URL(string: serial.poster)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.system(size: 40))
                    )
            }
            .frame(height: 400)
            .clipped()
            
            // Gradient Overlay
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Title and Info
            VStack(alignment: .leading, spacing: 12) {
                Text(serial.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                
                HStack(spacing: 16) {
                    Label(serial.episodes, systemImage: "tv")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Label("HD", systemImage: "4k.tv")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private var contentSection: some View {
        VStack(spacing: 20) {
            // Description Card
            VStack(alignment: .leading, spacing: 12) {
                Text("Tavsif")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Bu serial haqida batafsil ma'lumot. Qiziqarli syujet va ajoyib aktyorlik bilan sizni hayratda qoldiradi. Har bir epizod yangi sarguzashtlar va kutilmagan voqealar bilan to'la.")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal)
            
            // Info Cards
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                InfoCard(
                    title: "Janr",
                    value: "Drama, Komediya",
                    icon: "theatermasks"
                )
                
                InfoCard(
                    title: "Yil",
                    value: "2024",
                    icon: "calendar"
                )
                
                InfoCard(
                    title: "Reyting",
                    value: "8.5/10",
                    icon: "star.fill"
                )
                
                InfoCard(
                    title: "Davomiyligi",
                    value: "45 daqiqa",
                    icon: "clock"
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 20)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Play Button
            Button(action: {
                viewModel.playSerial(serial)
            }) {
                HStack(spacing: 12) {
                    if case .loading = viewModel.playState {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "play.fill")
                            .font(.title2)
                    }
                    
                    Text(playButtonText)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            .disabled(viewModel.playState == .loading)
            
            // Error Message
            if case .error(let message) = viewModel.playState {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    
                    Text(message)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            
            // Secondary Actions
            HStack(spacing: 12) {
                SecondaryActionButton(
                    title: "Sevimlilar",
                    icon: "heart",
                    action: {
                        // Add to favorites
                    }
                )
                
                SecondaryActionButton(
                    title: "Keyinroq",
                    icon: "bookmark",
                    action: {
                        // Add to watch later
                    }
                )
                
                SecondaryActionButton(
                    title: "Ulashish",
                    icon: "square.and.arrow.up",
                    action: {
                        showingShareSheet = true
                    }
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var playButtonText: String {
        switch viewModel.playState {
        case .loading:
            return "Ochilmoqda..."
        case .error:
            return "Qayta urinish"
        default:
            return "Tomosha qilish"
        }
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct SecondaryActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.system(.caption, design: .rounded, weight: .medium))
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SerialDetailView(
        serial: Serial(
            id: 1,
            title: "Test Serial Uzun Nomi Bilan",
            episodes: "24 Episodes",
            poster: "https://via.placeholder.com/300x450"
        )
    )
}