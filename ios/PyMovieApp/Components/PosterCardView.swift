import SwiftUI

struct PosterCardView: View {
    let serial: Serial

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImageView(url: serial.poster)
                .frame(width: 140, height: 210)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    Theme.cardGradient
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(serial.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                Text(serial.episodes)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(10)
        }
        .shadow(color: Color.black.opacity(0.6), radius: 10, x: 0, y: 8)
    }
}

