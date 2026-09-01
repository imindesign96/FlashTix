import Foundation
@testable import FlashTix

enum AuthenticationStubError: Error, Sendable {
    case notConfigured
    case rejected
}

actor InMemorySessionStore: SessionStoring {
    private var session: AuthSession?

    init(session: AuthSession? = nil) {
        self.session = session
    }

    func load() async throws -> AuthSession? {
        session
    }

    func save(_ session: AuthSession) async throws {
        self.session = session
    }

    func clear() async throws {
        session = nil
    }
}

actor AuthenticationAPIStub: AuthenticationServing {
    private let loginResult: Result<AuthSession, AuthenticationStubError>
    private let registerResult: Result<AuthSession, AuthenticationStubError>
    private let refreshResult: Result<AuthSession, AuthenticationStubError>
    private let refreshDelayNanoseconds: UInt64
    private(set) var refreshCallCount = 0
    private(set) var logoutCallCount = 0

    init(
        loginResult: Result<AuthSession, AuthenticationStubError> = .failure(.notConfigured),
        registerResult: Result<AuthSession, AuthenticationStubError> = .failure(.notConfigured),
        refreshResult: Result<AuthSession, AuthenticationStubError> = .failure(.notConfigured),
        refreshDelayNanoseconds: UInt64 = 0
    ) {
        self.loginResult = loginResult
        self.registerResult = registerResult
        self.refreshResult = refreshResult
        self.refreshDelayNanoseconds = refreshDelayNanoseconds
    }

    func register(email: String, password: String, displayName: String) async throws -> AuthSession {
        try registerResult.get()
    }

    func login(email: String, password: String) async throws -> AuthSession {
        try loginResult.get()
    }

    func refresh(refreshToken: String) async throws -> AuthSession {
        refreshCallCount += 1
        if refreshDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: refreshDelayNanoseconds)
        }
        return try refreshResult.get()
    }

    func logout(refreshToken: String) async throws {
        logoutCallCount += 1
    }
}

func makeSession(
    accessToken: String = "access-token",
    refreshToken: String = "refresh-token"
) -> AuthSession {
    AuthSession(
        user: AuthenticatedUser(
            id: UUID(uuidString: "9D95CD0E-9D64-49D7-A3EA-63E164608D3E")!,
            email: "alex@example.com",
            displayName: "Alex"
        ),
        tokens: AuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            accessTokenExpiresAt: Date(timeIntervalSince1970: 1_788_225_300)
        )
    )
}
