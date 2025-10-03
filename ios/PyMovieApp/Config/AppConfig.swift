import Foundation

enum AppConfig {
    // Update this to match your backend address
    static var baseURL: URL {
        if let override = UserDefaults.standard.string(forKey: "BASE_URL"), let url = URL(string: override) {
            return url
        }
        // Use 127.0.0.1 for Simulator, device requires your machine's LAN IP
        return URL(string: "http://127.0.0.1:5001")!
    }
}

