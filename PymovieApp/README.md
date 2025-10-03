# Pymovie iOS App

A professional iOS mobile application for discovering and streaming movies and TV series, integrated with a FastAPI backend and Telegram bot for content delivery.

## Features

### 🎬 Content Discovery
- **Latest Releases**: Browse the newest movies and series
- **Classic Collection**: Explore older, timeless content
- **Random Discovery**: Find hidden gems with random recommendations
- **Advanced Search**: Real-time search with intelligent filtering

### 🔍 Search & Discovery
- **Real-time Search**: Instant search results as you type
- **Smart Filtering**: Advanced search algorithms with transliteration support
- **Popular Searches**: Quick access to trending content
- **Search History**: Keep track of your recent searches

### ❤️ Personalization
- **Favorites**: Save your favorite movies and series
- **Personal Collections**: Organize content your way
- **Recommendations**: Get personalized suggestions

### 📱 Professional UI/UX
- **Modern Design**: Clean, intuitive interface following iOS design guidelines
- **Dark Mode**: Beautiful dark theme optimized for content viewing
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Responsive Layout**: Optimized for all iPhone and iPad sizes

### 🔗 Telegram Integration
- **Seamless Playback**: Direct integration with Telegram bot for content streaming
- **One-tap Access**: Instant access to movies and series
- **Share Functionality**: Share content with friends easily
- **Fallback Support**: Web fallback if Telegram app is not installed

## Technical Architecture

### 🏗️ Architecture Pattern
- **MVVM**: Model-View-ViewModel architecture for clean separation of concerns
- **Combine Framework**: Reactive programming for data flow
- **Async/Await**: Modern concurrency for network operations
- **Dependency Injection**: Clean dependency management

### 📡 Networking
- **URLSession**: Robust networking with retry mechanisms
- **Error Handling**: Comprehensive error handling and user feedback
- **Caching**: Intelligent caching for better performance
- **Rate Limiting**: Built-in rate limiting and request management

### 🎨 UI Components
- **SwiftUI**: Modern declarative UI framework
- **Custom Components**: Reusable, professional UI components
- **Animations**: Smooth, performant animations
- **Accessibility**: Full accessibility support

## Project Structure

```
PymovieApp/
├── Models.swift              # Data models and structures
├── NetworkManager.swift      # Networking layer
├── ViewModels.swift          # View models for MVVM
├── Components.swift          # Reusable UI components
├── HomeView.swift           # Home screen implementation
├── SearchView.swift         # Search functionality
├── SerialDetailView.swift   # Content detail view
├── ContentView.swift        # Main app container
├── PymovieAppApp.swift      # App entry point
├── TelegramIntegration.swift # Telegram bot integration
└── Assets.xcassets/         # App assets and resources
```

## API Integration

The app integrates with a FastAPI backend providing the following endpoints:

- `GET /api/serials/latest` - Latest 300 serials
- `GET /api/serials/oldest` - Oldest 300 serials
- `GET /api/serials/random` - Random 300 serials
- `GET /api/serials/search?query={query}` - Search functionality
- `POST /api/play` - Generate Telegram bot links

## Requirements

- **iOS 17.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- **FastAPI Backend** (running on configured URL)

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd PymovieApp
   ```

2. **Open in Xcode**
   ```bash
   open PymovieApp.xcodeproj
   ```

3. **Configure Backend URL**
   - Update `AppConfig.baseURL` in `Models.swift` with your backend URL
   - Ensure your FastAPI backend is running and accessible

4. **Build and Run**
   - Select your target device or simulator
   - Press Cmd+R to build and run

## Configuration

### Backend Configuration
Update the base URL in `Models.swift`:

```swift
struct AppConfig {
    static let baseURL = "http://your-backend-url:5001"
    // ... other configuration
}
```

### Telegram Bot Configuration
Update the bot username in `TelegramIntegration.swift`:

```swift
private let telegramBotUsername = "your_bot_username"
```

## Features in Detail

### Home Screen
- **Hero Section**: Featured content with large posters
- **Category Sections**: Latest, Classic, and Discovery sections
- **Quick Actions**: Search, Favorites, and Random content access
- **Smooth Scrolling**: Optimized horizontal scrolling for content discovery

### Search Experience
- **Real-time Search**: Debounced search with instant results
- **Search Suggestions**: Popular searches and recent history
- **Filter Options**: Advanced filtering capabilities
- **Empty States**: Helpful empty states with call-to-action

### Content Detail
- **Rich Information**: Detailed content information and metadata
- **Episode Management**: For TV series, organized episode listing
- **Play Integration**: One-tap play via Telegram bot
- **Social Features**: Share and favorite functionality

### Telegram Integration
- **Deep Linking**: Direct links to specific content
- **App Detection**: Automatic detection of Telegram installation
- **Fallback Support**: Web fallback for non-Telegram users
- **Share Functionality**: Easy content sharing

## Performance Optimizations

- **Lazy Loading**: Images and content loaded on demand
- **Memory Management**: Efficient memory usage with proper cleanup
- **Network Optimization**: Request batching and caching
- **UI Performance**: Smooth 60fps animations and transitions

## Accessibility

- **VoiceOver Support**: Full VoiceOver compatibility
- **Dynamic Type**: Support for all text size preferences
- **High Contrast**: Support for high contrast mode
- **Reduced Motion**: Respects user's motion preferences

## Error Handling

- **Network Errors**: Graceful handling of network issues
- **User Feedback**: Clear error messages and recovery options
- **Retry Mechanisms**: Automatic retry for failed requests
- **Offline Support**: Basic offline functionality

## Future Enhancements

- **Push Notifications**: New content notifications
- **Offline Downloads**: Download content for offline viewing
- **User Accounts**: User profiles and personalized recommendations
- **Social Features**: User reviews and ratings
- **Multiple Languages**: Internationalization support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

---

**Built with ❤️ using SwiftUI and modern iOS development practices**