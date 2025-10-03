import SwiftUI

@main
struct PymovieAppApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var userPreferences = UserPreferences()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .environmentObject(userPreferences)
                .preferredColorScheme(userPreferences.darkModeEnabled ? .dark : .light)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Configure app appearance
        configureAppearance()
        
        // Setup notifications
        setupNotifications()
        
        // Initialize analytics (if needed)
        initializeAnalytics()
    }
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Color.backgroundColor)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.textPrimary)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.cardBackground)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Configure status bar
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    private func setupNotifications() {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func initializeAnalytics() {
        // Initialize analytics services
        // This is where you would integrate services like Firebase Analytics, Mixpanel, etc.
        print("Analytics initialized")
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // App launch configuration
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle push notifications
        completionHandler(.newData)
    }
}

// MARK: - App Configuration
struct AppConfiguration {
    static let version = "1.0.0"
    static let buildNumber = "1"
    static let appName = "Pymovie"
    static let bundleIdentifier = "com.pymovie.app"
    
    // API Configuration
    static let apiBaseURL = "http://localhost:5001"
    static let apiTimeout: TimeInterval = 30
    static let maxRetries = 3
    
    // UI Configuration
    static let animationDuration: Double = 0.3
    static let hapticFeedbackEnabled = true
    static let debugMode = false
}

// MARK: - App Constants
struct AppConstants {
    // Image sizes
    static let posterAspectRatio: CGFloat = 2/3
    static let heroImageHeight: CGFloat = 300
    static let cardHeight: CGFloat = 200
    
    // Spacing
    static let defaultPadding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let largePadding: CGFloat = 24
    
    // Corner radius
    static let defaultCornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let largeCornerRadius: CGFloat = 16
    
    // Animation
    static let defaultAnimationDuration: Double = 0.3
    static let fastAnimationDuration: Double = 0.1
    static let slowAnimationDuration: Double = 0.6
}

// MARK: - App Utilities
struct AppUtilities {
    static func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    static func shareContent(_ items: [Any]) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        window.rootViewController?.present(activityViewController, animated: true)
    }
    
    static func showAlert(title: String, message: String, buttonTitle: String = "OK") {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default))
        
        window.rootViewController?.present(alert, animated: true)
    }
}

// MARK: - App Extensions
extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var appName: String {
        return infoDictionary?["CFBundleDisplayName"] as? String ?? "Pymovie"
    }
}

// MARK: - Device Information
struct DeviceInfo {
    static var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var hasNotch: Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return false }
        return windowScene.windows.first?.safeAreaInsets.top ?? 0 > 20
    }
}