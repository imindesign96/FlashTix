import XCTest
@testable import FlashTix

@MainActor
final class HomeViewModelTests: XCTestCase {
    func test_load_publishesFetchedEvents() async {
        let event = EventSummary(
            id: UUID(),
            title: "Coldplay",
            subtitle: "Music of the Spheres World Tour",
            venue: "National Stadium, Hanoi",
            startsAt: Date(),
            imageURL: nil,
            minimumPrice: 1_200_000,
            currency: "VND"
        )
        let repository = EventRepositoryStub(result: .success([event]))
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .loaded([event]))
    }
}

private struct EventRepositoryStub: EventRepository {
    let result: Result<[EventSummary], Error>

    func fetchFeaturedEvents() async throws -> [EventSummary] {
        try result.get()
    }
}
