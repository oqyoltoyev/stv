import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                LinearGradient(
                    colors: [Theme.accent, Theme.accent.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: Theme.accent.opacity(configuration.isPressed ? 0.2 : 0.4), radius: 12, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

