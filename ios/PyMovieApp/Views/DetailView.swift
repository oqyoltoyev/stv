import SwiftUI

struct DetailView: View {
    let serial: Serial
    @StateObject private var viewModel = DetailViewModel()
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RemoteImageView(url: serial.poster)
                    .frame(height: 320)
                    .overlay(LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.9)], startPoint: .center, endPoint: .bottom))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text(serial.title)
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text(serial.episodes)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    Button {
                        Task { await viewModel.requestPlay(for: serial.id) }
                    } label: {
                        Label("Play", systemImage: "play.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.playURL) { _, url in
            guard let url else { return }
            Haptics.success()
            openURL(url)
        }
        .overlay(alignment: .top) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.white)
                    .padding(8)
                    .glassBackground()
                    .padding()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

