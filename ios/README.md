## PyMovie iOS (SwiftUI)

Ultra-professional SwiftUI client for the provided FastAPI backend.

### Prerequisites
- Xcode 15+
- iOS 16+ target (can lower to iOS 15 with minor tweaks)

### Getting Started
1. Open Xcode and create a new iOS App project named `PyMovieApp` (SwiftUI, Swift).
2. Close Xcode. Copy the contents of this `ios/` folder into your project directory.
3. Re-open the project. Ensure the files under `PyMovieApp/` are added to the target (check the Target Membership in Xcode).
4. Configure the backend URL in `PyMovieApp/Config/AppConfig.swift`:
   - For Simulator (backend on the same machine): `http://127.0.0.1:5001`
   - For Device (backend on your computer): `http://<your-computer-LAN-ip>:5001`

### App Transport Security (ATS)
If your backend is HTTP (not HTTPS), add ATS exception to `Info.plist`:
```
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key><true/>
  <key>NSExceptionDomains</key>
  <dict>
    <key>localhost</key>
    <dict>
      <key>NSExceptionAllowsInsecureHTTPLoads</key><true/>
      <key>NSIncludesSubdomains</key><true/>
    </dict>
  </dict>
  <key>NSAllowsArbitraryLoadsInWebContent</key><true/>
  <key>NSAllowsLocalNetworking</key><true/>
  <key>NSAllowsArbitraryLoadsForMedia</key><true/>
  <key>NSAllowsArbitraryLoadsForWebContent</key><true/>
  <key>NSAllowsArbitraryLoadsInSecureContexts</key><true/>
  <key>NSAllowsArbitraryLoadsInNetworkExtensions</key><true/>
  <key>NSAllowsArbitraryLoadsInHTTPSErrors</key><true/>
  <key>NSAllowsArbitraryLoadsAndTLSMinimumVersion</key><string>TLSv1.0</string>
  <key>NSAllowsArbitraryLoadsKey</key><true/>
  <key>NSAllowsArbitraryLoadsForMediaKey</key><true/>
  <key>NSAllowsArbitraryLoadsForWebContentKey</key><true/>
  <key>NSAllowsLocalNetworkingKey</key><true/>
  <key>NSAllowsInsecureHTTPLoads</key><true/>
  <key>NSAllowsInsecureHTTPLoadsKey</key><true/>
  <key>NSIncludesSubdomains</key><true/>
  <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key><true/>
  <key>NSTemporaryExceptionMinimumTLSVersion</key><string>TLSv1.0</string>
  <key>NSAllowsArbitraryLoadsExceptionDomains</key>
  <dict/>
  <key>NSAllowsArbitraryLoadsExceptionDomainsKey</key>
  <dict/>
  </dict>
```
For production, replace with a precise exception domain for your backend.

### Features
- SwiftUI, MVVM, async/await networking
- Home (Latest, Random, Oldest)
- Search with debounced queries
- Detail with Play action (opens Telegram bot link)
- Shimmer loading states, haptics, modern glass/blur design

### Files Overview
- `PyMovieApp/PyMovieApp.swift`: App entry and tabs
- `Config/AppConfig.swift`: Base URL configuration
- `Models/Serial.swift`: API models
- `Networking/ApiClient.swift`: API layer
- `Utilities/`: Debouncer, Haptics
- `DesignSystem/`: Colors, gradients, typography
- `Components/`: Cards, AsyncImage, Shimmer
- `ViewModels/`: Home, Search, Detail VMs
- `Views/`: Screens

### Run
1. Set `AppConfig.baseURL`.
2. Ensure ATS rules in `Info.plist`.
3. Run on Simulator or Device. Use Pull-to-Refresh on Home to reload.

### File Structure
```
ios/
  README.md
  PyMovieApp/
    PyMovieApp.swift
    Config/
      AppConfig.swift
    Models/
      Serial.swift
    Networking/
      ApiClient.swift
    Utilities/
      Debouncer.swift
      Haptics.swift
    DesignSystem/
      Theme.swift
    Components/
      ShimmerView.swift
      RemoteImageView.swift
      PosterCardView.swift
      SectionHeaderView.swift
      PrimaryButtonStyle.swift
    ViewModels/
      HomeViewModel.swift
      SearchViewModel.swift
      DetailViewModel.swift
    Views/
      HomeView.swift
      SearchView.swift
      DetailView.swift
```

### Notes
- The app uses `AsyncImage`, consider SDWebImageSwiftUI if you prefer advanced caching.
- For production, migrate to HTTPS and tighten ATS exceptions.
- If running on a physical device, set your machine's LAN IP in `AppConfig.baseURL`.

