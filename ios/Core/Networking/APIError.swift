import Foundation

enum APIError: Error, Equatable, Sendable {
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed
}
