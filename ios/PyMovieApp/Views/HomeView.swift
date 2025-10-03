import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        heroHeader

                        section(title: "Latest", items: viewModel.latest)
                        section(title: "Random", items: viewModel.randoms)
                        section(title: "Oldest", items: viewModel.oldest)
                    }
                    .padding(.vertical, 16)
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
            .navigationTitle("PyMovie")
            .toolbar { toolbarContent }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load(force: true) }
    }

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            if let hero = viewModel.latest.first ?? viewModel.randoms.first ?? viewModel.oldest.first {
                RemoteImageView(url: hero.poster)
                    .frame(height: 260)
                    .overlay(LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.9)], startPoint: .center, endPoint: .bottom))
                    .clipped()

                VStack(alignment: .leading, spacing: 8) {
                    Text(hero.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text(hero.episodes)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    NavigationLink(destination: DetailView(serial: hero)) {
                        Label("Open", systemImage: "play.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
            } else {
                ZStack {
                    Color.gray.opacity(0.2).frame(height: 260)
                    ShimmerView().frame(height: 260)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal)
    }

    private func section(title: String, items: [Serial]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: title)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(items) { item in
                        NavigationLink(destination: DetailView(serial: item)) {
                            PosterCardView(serial: item)
                        }
                        .buttonStyle(.plain)
                    }
                    if items.isEmpty {
                        ForEach(0..<6, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(ShimmerView())
                                .frame(width: 140, height: 210)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(destination: SearchView()) {
                Image(systemName: "magnifyingglass")
            }
        }
    }
}

