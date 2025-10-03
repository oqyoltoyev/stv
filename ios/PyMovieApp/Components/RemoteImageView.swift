import SwiftUI

struct RemoteImageView: View {
    let url: URL?

    var body: some View {
        ZStack {
            if let url {
                AsyncImage(url: url, transaction: .init(animation: .easeInOut)) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.25)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white.opacity(0.5))
                            .padding(24)
                            .background(Color.gray.opacity(0.2))
                    @unknown default:
                        Color.gray.opacity(0.25)
                    }
                }
            } else {
                Color.gray.opacity(0.25)
            }
        }
        .clipped()
    }
}

