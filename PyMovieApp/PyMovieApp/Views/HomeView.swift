import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var latestSerials: [Serial] = []
    @Published var oldestSerials: [Serial] = []
    @Published var randomSerials: [Serial] = []
    
    @Published var latestState: LoadingState = .idle
    @Published var oldestState: LoadingState = .idle
    @Published var randomState: LoadingState = .idle
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadAllSections()
    }
    
    func loadAllSections() {
        loadLatestSerials()
        loadOldestSerials()
        loadRandomSerials()
    }
    
    private func loadLatestSerials() {
        latestState = .loading
        
        networkService.fetchLatestSerials()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.latestState = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] serials in
                    self?.latestSerials = serials
                    self?.latestState = .loaded
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadOldestSerials() {
        oldestState = .loading
        
        networkService.fetchOldestSerials()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.oldestState = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] serials in
                    self?.oldestSerials = serials
                    self?.oldestState = .loaded
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadRandomSerials() {
        randomState = .loading
        
        networkService.fetchRandomSerials()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.randomState = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] serials in
                    self?.randomSerials = serials
                    self?.randomState = .loaded
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshSection(_ type: SectionType) {
        switch type {
        case .latest:
            loadLatestSerials()
        case .oldest:
            loadOldestSerials()
        case .random:
            loadRandomSerials()
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedSerial: Serial?
    @State private var showingDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Latest Serials Section
                    serialSection(
                        title: "Yangi seriallar",
                        icon: "clock.fill",
                        serials: viewModel.latestSerials,
                        state: viewModel.latestState,
                        type: .latest
                    )
                    
                    // Random Serials Section
                    serialSection(
                        title: "Tasodifiy seriallar",
                        icon: "shuffle",
                        serials: viewModel.randomSerials,
                        state: viewModel.randomState,
                        type: .random
                    )
                    
                    // Oldest Serials Section
                    serialSection(
                        title: "Eski seriallar",
                        icon: "calendar",
                        serials: viewModel.oldestSerials,
                        state: viewModel.oldestState,
                        type: .oldest
                    )
                    
                    // Bottom spacing
                    Color.clear.frame(height: 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("PyMovie")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.loadAllSections()
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let serial = selectedSerial {
                SerialDetailView(serial: serial)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Salom! 👋")
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Bugun nima ko'rasiz?")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.loadAllSections()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func serialSection(
        title: String,
        icon: String,
        serials: [Serial],
        state: LoadingState,
        type: SectionType
    ) -> some View {
        VStack(spacing: 12) {
            SectionHeaderView(title: title, icon: icon)
            
            switch state {
            case .idle, .loading:
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { _ in
                            SerialCardShimmer()
                                .frame(width: 120)
                        }
                    }
                    .padding(.horizontal)
                }
                
            case .loaded:
                if serials.isEmpty {
                    EmptyStateView(
                        title: "Ma'lumot topilmadi",
                        message: "Hozircha bu bo'limda seriallar yo'q",
                        systemImage: "tv"
                    )
                    .frame(height: 200)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(serials.prefix(20)) { serial in
                                SerialCardView(serial: serial) {
                                    selectedSerial = serial
                                    showingDetail = true
                                }
                                .frame(width: 120)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
            case .error(let message):
                ErrorView(message: message) {
                    viewModel.refreshSection(type)
                }
                .frame(height: 200)
            }
        }
    }
}

#Preview {
    HomeView()
}