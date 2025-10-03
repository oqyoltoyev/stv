import SwiftUI

enum Theme {
    static let background = Color.black
    static let surface = Color(white: 0.08)
    static let surfaceElevated = Color(white: 0.12)
    static let primary = Color.white
    static let secondary = Color(white: 0.7)
    static let accent = Color(red: 0.96, green: 0.23, blue: 0.33)

    static let cardGradient = LinearGradient(
        gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.85)]),
        startPoint: .top,
        endPoint: .bottom
    )
}

extension View {
    func glassBackground() -> some View {
        self.background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

