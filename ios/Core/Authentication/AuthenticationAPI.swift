import Foundation

protocol AuthenticationServing: Sendable {
    func register(email: String, password: String, displayName: String) async throws -> AuthSession
    func login(email: String, password: String) async throws -> AuthSession
    func refresh(refreshToken: String) async throws -> AuthSession
    func logout(refreshToken: String) async throws
}

struct LiveAuthenticationAPI: AuthenticationServing {
    let client: APIClient

    func register(email: String, password: String, displayName: String) async throws -> AuthSession {
        try await client.post(
            "api/v1/auth/register",
            body: RegisterBody(email: email, password: password, displayName: displayName)
        )
    }

    func login(email: String, password: String) async throws -> AuthSession {
        try await client.post(
            "api/v1/auth/login",
            body: LoginBody(email: email, password: password)
        )
    }

    func refresh(refreshToken: String) async throws -> AuthSession {
        try await client.post(
            "api/v1/auth/refresh",
            body: RefreshBody(refreshToken: refreshToken)
        )
    }

    func logout(refreshToken: String) async throws {
        try await client.post(
            "api/v1/auth/logout",
            body: RefreshBody(refreshToken: refreshToken)
        )
    }
}

private struct RegisterBody: Encodable, Sendable {
    let email: String
    let password: String
    let displayName: String
}

private struct LoginBody: Encodable, Sendable {
    let email: String
    let password: String
}

private struct RefreshBody: Encodable, Sendable {
    let refreshToken: String
}
