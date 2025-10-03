# PyMovie iOS App

Professional iOS mobile application for PyMovie.uz backend with ultra-modern design.

## Features

### 🏠 Home Screen
- **Latest Serials**: 300 newest series and movies
- **Random Content**: Discover new content with randomized recommendations
- **Classic Collection**: Browse older series and movies
- **Pull-to-refresh** functionality
- **Shimmer loading** animations

### 🔍 Search
- **Real-time search** with 500ms debounce
- **Recent searches** with local storage
- **Advanced search algorithm** matching your backend's scoring system
- **Empty states** and error handling

### 📱 Serial Detail
- **Hero image** with gradient overlay
- **Play functionality** that opens Telegram bot links
- **Share functionality** 
- **Modern card-based** information display
- **Loading states** and error handling

### 🎨 Design Features
- **Dark mode** support
- **Professional animations** and transitions
- **Modern iOS design** with rounded corners and shadows
- **Responsive layout** for all iPhone and iPad sizes
- **Accessibility** support

## Technical Architecture

### 📦 Project Structure
```
PyMovieApp/
├── Models.swift              # Data models and enums
├── NetworkService.swift      # API communication layer
├── Views/
│   ├── HomeView.swift       # Home screen with sections
│   ├── SearchView.swift     # Search functionality
│   └── SerialDetailView.swift # Detail screen
├── Components/
│   ├── SerialCardView.swift # Reusable card components
│   └── LoadingView.swift    # Loading and error states
└── Assets.xcassets/         # App icons and colors
```

### 🔧 Technologies Used
- **SwiftUI** for modern declarative UI
- **Combine** for reactive programming
- **URLSession** for networking
- **AsyncImage** for image loading
- **UserDefaults** for local storage

### 🌐 Backend Integration
The app connects to your FastAPI backend at `http://localhost:5001` with these endpoints:
- `GET /api/serials/latest` - Latest 300 serials
- `GET /api/serials/oldest` - Oldest 300 serials  
- `GET /api/serials/random` - Random 300 serials
- `GET /api/serials/search?query=` - Search functionality
- `POST /api/play` - Get Telegram bot link for playing

## Setup Instructions

### 1. Configure Backend URL
In `NetworkService.swift`, update the `baseURL`:
```swift
private let baseURL = "https://your-backend-url.com"
```

### 2. Build Requirements
- **Xcode 15.0+**
- **iOS 17.0+** deployment target
- **Swift 5.9+**

### 3. Run the App
1. Open `PyMovieApp.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press `Cmd+R` to build and run

## Key Features Implementation

### 🎯 Smart Search
- Debounced search (500ms delay)
- Recent searches storage
- Real-time results
- Empty states handling

### 🎨 Modern UI Components
- **SerialCardView**: Compact cards for horizontal scrolling
- **LargeSerialCardView**: Detailed cards for search results
- **LoadingView**: Animated loading indicators
- **ShimmerView**: Skeleton loading animations
- **ErrorView**: User-friendly error messages

### 📱 Responsive Design
- Adaptive layouts for iPhone and iPad
- Dark mode support
- Accessibility features
- Smooth animations and transitions

### 🔄 State Management
- **MVVM architecture** with ObservableObject
- **Loading states**: idle, loading, loaded, error
- **Combine publishers** for reactive data flow
- **Error handling** with user-friendly messages

## Customization

### 🎨 Colors and Styling
- Primary color: Blue (`Color.blue`)
- Background: System grouped background
- Cards: System background with shadows
- Text: System primary and secondary colors

### 🖼️ Images and Assets
- App icon placeholder in `Assets.xcassets`
- Accent color configuration
- SF Symbols for icons

### 📝 Localization
Currently in Uzbek language. To add more languages:
1. Add localization files
2. Update text strings
3. Configure language settings

## Performance Optimizations

- **Lazy loading** with LazyVStack and LazyHStack
- **Image caching** with AsyncImage
- **Debounced search** to reduce API calls
- **Efficient list rendering** with ForEach and identifiable items
- **Memory management** with proper Combine cancellables

## Error Handling

- Network connectivity issues
- API response errors
- Image loading failures
- User-friendly error messages
- Retry functionality

This iOS app provides a professional, modern interface for your PyMovie.uz backend with excellent user experience and performance.