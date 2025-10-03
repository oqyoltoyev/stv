import SwiftUI

struct ShimmerView: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        Rectangle()
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.35), Color.white.opacity(0.15)]),
                startPoint: .leading,
                endPoint: .trailing
            ))
            .mask(
                Rectangle()
                    .fill(Color.white)
                    .rotationEffect(.degrees(30))
                    .offset(x: phase * 300)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

