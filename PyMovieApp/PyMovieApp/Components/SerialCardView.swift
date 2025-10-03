import SwiftUI

struct SerialCardView: View {
    let serial: Serial
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Poster Image
                AsyncImage(url: URL(string: serial.poster)) { image in
                    image
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(2/3, contentMode: .fill)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.title2)
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                
                // Title and Episodes
                VStack(alignment: .leading, spacing: 4) {
                    Text(serial.title)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(serial.episodes)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

struct LargeSerialCardView: View {
    let serial: Serial
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Poster Image
                AsyncImage(url: URL(string: serial.poster)) { image in
                    image
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(2/3, contentMode: .fill)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.title2)
                        )
                }
                .frame(width: 80, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(serial.title)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    Text(serial.episodes)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        
                        Text("Tomosha qilish")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SectionHeaderView: View {
    let title: String
    let icon: String
    let onSeeAll: (() -> Void)?
    
    init(title: String, icon: String, onSeeAll: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.onSeeAll = onSeeAll
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text(title)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            if let onSeeAll = onSeeAll {
                Button(action: onSeeAll) {
                    HStack(spacing: 4) {
                        Text("Barchasi")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 20) {
        SectionHeaderView(title: "Yangi seriallar", icon: "clock.fill") {
            print("See all tapped")
        }
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(0..<5) { _ in
                    SerialCardView(
                        serial: Serial(
                            id: 1,
                            title: "Test Serial Nomi",
                            episodes: "24 Episodes",
                            poster: "https://via.placeholder.com/300x450"
                        )
                    ) {
                        print("Card tapped")
                    }
                    .frame(width: 120)
                }
            }
            .padding(.horizontal)
        }
        
        LargeSerialCardView(
            serial: Serial(
                id: 1,
                title: "Test Serial Uzun Nomi Bilan",
                episodes: "24 Episodes",
                poster: "https://via.placeholder.com/300x450"
            )
        ) {
            print("Large card tapped")
        }
        .padding(.horizontal)
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}