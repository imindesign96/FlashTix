import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(repository: any EventRepository) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                header
                searchBar
                categoryRow
                content
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.retry()
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hi, Alex 👋")
                    .font(.title2.bold())
                Text("Find your next experience")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.title3)
                    .foregroundStyle(FlashTixColor.ink)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            Text("Search events, artists, venues...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                CategoryChip(title: "All", icon: "sparkles")
                CategoryChip(title: "Concerts", icon: "music.mic")
                CategoryChip(title: "Sports", icon: "soccerball")
                CategoryChip(title: "Theater", icon: "theatermasks")
                CategoryChip(title: "More", icon: "ellipsis")
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading events...")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 220)

        case .loaded(let events):
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Recommended for you")
                        .font(.headline)
                    Spacer()
                    Text("See all")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(FlashTixColor.brandPink)
                }

                ForEach(events) { event in
                    EventCard(event: event)
                }
            }

        case .failed(let message):
            ContentUnavailableView {
                Label("Events unavailable", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") {
                    Task { await viewModel.retry() }
                }
            }
            .frame(minHeight: 260)
        }
    }
}

private struct CategoryChip: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 7) {
            ZStack {
                Circle()
                    .fill(FlashTixColor.ink)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundStyle(.white)
            }
            Text(title)
                .font(.caption2)
                .foregroundStyle(.primary)
        }
    }
}

private struct EventCard: View {
    let event: EventSummary

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: event.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle()
                        .fill(FlashTixColor.brandGradient)
                }
            }
            .frame(height: 230)
            .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.85)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(event.title)
                    .font(.title3.bold())
                Text(event.subtitle)
                    .font(.subheadline)
                Text(event.venue)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Text("From \(event.minimumPrice.formatted(.number)) \(event.currency)")
                    .font(.subheadline.weight(.semibold))
                    .padding(.top, 4)
            }
            .foregroundStyle(.white)
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
