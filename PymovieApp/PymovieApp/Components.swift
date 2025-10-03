import SwiftUI

// MARK: - Custom Colors
extension Color {
    static let primaryColor = Color(red: 0.2, green: 0.3, blue: 0.8)
    static let secondaryColor = Color(red: 0.9, green: 0.9, blue: 0.95)
    static let accentColor = Color(red: 1.0, green: 0.4, blue: 0.2)
    static let backgroundColor = Color(red: 0.05, green: 0.05, blue: 0.1)
    static let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.8)
}

// MARK: - Custom Fonts
extension Font {
    static let largeTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 18, weight: .medium, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 14, weight: .regular, design: .rounded)
    static let smallCaption = Font.system(size: 12, weight: .regular, design: .rounded)
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.primaryColor, lineWidth: 4)
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.textSecondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.accentColor)
            
            Text("Something went wrong")
                .font(.title)
                .foregroundColor(.textPrimary)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.primaryColor)
                .cornerRadius(12)
            }
        }
        .padding()
    }
}

// MARK: - Serial Card
struct SerialCard: View {
    let serial: Serial
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster Image
            AsyncImage(url: URL(string: serial.poster)) { image in
                image
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBackground)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.textSecondary)
                    )
            }
            .frame(height: 200)
            .clipped()
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryColor.opacity(0.3), lineWidth: 1)
            )
            
            // Title
            Text(serial.title)
                .font(.headline)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Episodes
            Text(serial.episodes)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.primaryColor.opacity(0.2))
                .cornerRadius(8)
        }
        .frame(width: 140)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0) { pressing in
            isPressed = pressing
        }
    }
}

// MARK: - Serial Grid
struct SerialGrid: View {
    let serials: [Serial]
    let onSerialTap: (Serial) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(serials) { serial in
                SerialCard(serial: serial) {
                    onSerialTap(serial)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let action: (() -> Void)?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            if let action = action {
                Button("See All", action: action)
                    .font(.headline)
                    .foregroundColor(.primaryColor)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            
            TextField("Search movies and series...", text: $text)
                .font(.body)
                .foregroundColor(.textPrimary)
                .onTapGesture {
                    isEditing = true
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEditing ? Color.primaryColor : Color.clear, lineWidth: 2)
        )
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }
}

// MARK: - Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: TabSelection
    
    var body: some View {
        HStack {
            ForEach(TabSelection.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .medium))
                        
                        Text(tab.rawValue)
                            .font(.smallCaption)
                    }
                    .foregroundColor(selectedTab == tab ? .primaryColor : .textSecondary)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.cardBackground)
    }
}

// MARK: - Play Button
struct PlayButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Play")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.primaryColor, Color.accentColor]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: Color.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0) { pressing in
            isPressed = pressing
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text(title)
                .font(.title)
                .foregroundColor(.textPrimary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Custom Divider
struct CustomDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.primaryColor.opacity(0.3))
            .frame(height: 1)
            .padding(.horizontal)
    }
}