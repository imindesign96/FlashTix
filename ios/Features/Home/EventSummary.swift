import Foundation

struct EventSummary: Decodable, Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let venue: String
    let startsAt: Date
    let imageURL: URL?
    let minimumPrice: Int
    let currency: String
}
