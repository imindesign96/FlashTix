import Foundation

struct AuthenticatedUser: Codable, Equatable, Sendable {
    let id: UUID
    let email: String
    let displayName: String
}

struct AuthTokens: Codable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresAt: Date
}

struct AuthSession: Codable, Equatable, Sendable {
    let user: AuthenticatedUser
    let tokens: AuthTokens
}

enum AuthenticationError: Error, Equatable, Sendable {
    case invalidSession
    case sessionExpired
}
