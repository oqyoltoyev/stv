import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated loading circles
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            
            Text("Yuklanmoqda...")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Xato yuz berdi")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.primary)
            
            Text(message)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Qayta urinish")
                }
                .font(.system(.headline, design: .rounded, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                )
            }
        }
        .padding()
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.primary)
            
            Text(message)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct ShimmerView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.1),
                        Color.gray.opacity(0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .mask(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.black, Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(70))
                    .offset(x: isAnimating ? 200 : -200)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

struct SerialCardShimmer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(2/3, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(ShimmerView())
            
            VStack(alignment: .leading, spacing: 4) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 12)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(ShimmerView())
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 10)
                    .frame(maxWidth: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(ShimmerView())
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        LoadingView()
        
        ErrorView(message: "Internet bilan bog'lanishda muammo") {
            print("Retry tapped")
        }
        
        EmptyStateView(
            title: "Hech narsa topilmadi",
            message: "Qidiruv so'zingizni o'zgartirib ko'ring",
            systemImage: "magnifyingglass"
        )
        
        HStack {
            SerialCardShimmer()
                .frame(width: 120)
            
            SerialCardShimmer()
                .frame(width: 120)
            
            SerialCardShimmer()
                .frame(width: 120)
        }
        .padding()
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}