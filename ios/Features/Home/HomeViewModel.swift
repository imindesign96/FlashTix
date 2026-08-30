import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded([EventSummary])
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    private let repository: any EventRepository

    init(repository: any EventRepository) {
        self.repository = repository
    }

    func load() async {
        guard state == .idle else { return }

        state = .loading

        do {
            let events = try await repository.fetchFeaturedEvents()
            try Task.checkCancellation()
            state = .loaded(events)
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failed("Could not load events. Check that the API is running and try again.")
        }
    }

    func retry() async {
        state = .idle
        await load()
    }
}
