import SwiftUI
import Foundation

// MARK: - Telegram Integration Manager
class TelegramIntegration: ObservableObject {
    static let shared = TelegramIntegration()
    
    @Published var isTelegramInstalled = false
    @Published var canOpenTelegram = false
    
    private let telegramBotUsername = "pymovibot"
    private let telegramAppURL = "tg://"
    private let telegramWebURL = "https://t.me/"
    
    init() {
        checkTelegramAvailability()
    }
    
    // MARK: - Check Telegram Availability
    private func checkTelegramAvailability() {
        if let telegramURL = URL(string: telegramAppURL) {
            isTelegramInstalled = UIApplication.shared.canOpenURL(telegramURL)
        }
        canOpenTelegram = isTelegramInstalled
    }
    
    // MARK: - Open Telegram Bot
    func openTelegramBot(serialId: Int) {
        let botURL = "\(telegramAppURL)\(telegramBotUsername)?start=s\(serialId)"
        
        if let url = URL(string: botURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url) { success in
                    if success {
                        HapticManager.shared.impact(.medium)
                    } else {
                        self.fallbackToWeb(serialId: serialId)
                    }
                }
            } else {
                fallbackToWeb(serialId: serialId)
            }
        } else {
            fallbackToWeb(serialId: serialId)
        }
    }
    
    // MARK: - Fallback to Web
    private func fallbackToWeb(serialId: Int) {
        let webURL = "\(telegramWebURL)\(telegramBotUsername)?start=s\(serialId)"
        
        if let url = URL(string: webURL) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Generate Bot Link
    func generateBotLink(serialId: Int) -> String {
        return "\(telegramWebURL)\(telegramBotUsername)?start=s\(serialId)"
    }
    
    // MARK: - Share Content
    func shareSerial(serial: Serial) {
        let shareText = "Check out this amazing content: \(serial.title)"
        let botLink = generateBotLink(serialId: serial.id)
        
        let items: [Any] = [shareText, botLink]
        AppUtilities.shareContent(items)
    }
}

// MARK: - Telegram Play Button
struct TelegramPlayButton: View {
    let serial: Serial
    @StateObject private var telegramIntegration = TelegramIntegration.shared
    @State private var isPlaying = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Button(action: playSerial) {
            HStack(spacing: 8) {
                if isPlaying {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(isPlaying ? "Opening..." : "Play in Telegram")
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
        .disabled(isPlaying)
        .alert("Telegram", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func playSerial() {
        isPlaying = true
        HapticManager.shared.impact(.light)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            telegramIntegration.openTelegramBot(serialId: serial.id)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isPlaying = false
            }
        }
    }
}

// MARK: - Telegram Status View
struct TelegramStatusView: View {
    @StateObject private var telegramIntegration = TelegramIntegration.shared
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: telegramIntegration.isTelegramInstalled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(telegramIntegration.isTelegramInstalled ? .green : .orange)
            
            Text(telegramIntegration.isTelegramInstalled ? "Telegram Ready" : "Install Telegram")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.cardBackground)
        .cornerRadius(8)
    }
}

// MARK: - Telegram Installation Prompt
struct TelegramInstallationPrompt: View {
    @State private var showingAppStore = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 40))
                .foregroundColor(.primaryColor)
            
            Text("Install Telegram")
                .font(.title)
                .foregroundColor(.textPrimary)
            
            Text("To watch content, you need to install Telegram from the App Store")
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingAppStore = true
            }) {
                HStack {
                    Image(systemName: "arrow.down.app")
                    Text("Install from App Store")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.primaryColor)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .padding()
        .sheet(isPresented: $showingAppStore) {
            AppStoreView()
        }
    }
}

// MARK: - App Store View
struct AppStoreView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.primaryColor)
                
                Text("Telegram")
                    .font(.largeTitle)
                    .foregroundColor(.textPrimary)
                
                Text("Fast, secure, and free messaging app")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    openAppStore()
                }) {
                    HStack {
                        Image(systemName: "arrow.down.app")
                        Text("Download from App Store")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryColor)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Install Telegram")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func openAppStore() {
        let appStoreURL = "https://apps.apple.com/app/telegram/id686449807"
        AppUtilities.openURL(appStoreURL)
    }
}

// MARK: - Telegram Share Sheet
struct TelegramShareSheet: View {
    let serial: Serial
    @StateObject private var telegramIntegration = TelegramIntegration.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Serial Info
                VStack(spacing: 12) {
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
                    .frame(width: 120, height: 180)
                    .clipped()
                    .cornerRadius(12)
                    
                    Text(serial.title)
                        .font(.title)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(serial.episodes)
                        .font(.body)
                        .foregroundColor(.textSecondary)
                }
                
                // Share Options
                VStack(spacing: 16) {
                    Button(action: {
                        telegramIntegration.shareSerial(serial: serial)
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share via Telegram")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryColor)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        UIPasteboard.general.string = telegramIntegration.generateBotLink(serialId: serial.id)
                        HapticManager.shared.notification(.success)
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Link")
                        }
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Telegram Integration Preview
struct TelegramIntegration_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TelegramPlayButton(serial: Serial(
                id: 1,
                title: "Sample Movie",
                episodes: "Movie",
                poster: "https://example.com/poster.jpg"
            ))
            
            TelegramStatusView()
        }
        .padding()
        .background(Color.backgroundColor)
        .preferredColorScheme(.dark)
    }
}