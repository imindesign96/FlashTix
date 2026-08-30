import Foundation

protocol EventRepository: Sendable {
    func fetchFeaturedEvents() async throws -> [EventSummary]
}

struct LiveEventRepository: EventRepository {
    let client: APIClient

    func fetchFeaturedEvents() async throws -> [EventSummary] {
        try await client.get("api/v1/events")
    }
}
