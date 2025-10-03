import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            content
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focused = true }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.7))
            TextField("Search movies, series...", text: $viewModel.query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .focused($focused)
            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(12)
        .glassBackground()
        .padding()
    }

    private var content: some View {
        Group {
            if viewModel.isSearching {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 14)], spacing: 14) {
                        ForEach(0..<12, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(ShimmerView())
                                .frame(height: 210)
                                .padding(.horizontal, 0)
                        }
                    }
                    .padding(.horizontal)
                }
            } else if !viewModel.results.isEmpty {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 14)], spacing: 14) {
                        ForEach(viewModel.results) { item in
                            NavigationLink(destination: DetailView(serial: item)) {
                                PosterCardView(serial: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "film.stack.fill").font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.6))
                    Text("Search movies and series")
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

