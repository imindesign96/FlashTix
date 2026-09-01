import Foundation

actor TokenManager {
    typealias InvalidationHandler = @Sendable () async -> Void

    private let store: any SessionStoring
    private let authenticationAPI: any AuthenticationServing
    private var session: AuthSession?
    private var hasRestoredSession = false
    private var refreshTask: Task<AuthSession, Error>?
    private var invalidationHandler: InvalidationHandler?

    init(store: any SessionStoring, authenticationAPI: any AuthenticationServing) {
        self.store = store
        self.authenticationAPI = authenticationAPI
    }

    func setInvalidationHandler(_ handler: @escaping InvalidationHandler) {
        invalidationHandler = handler
    }

    func restoreSession() async throws -> AuthSession? {
        if hasRestoredSession {
            return session
        }
        session = try await store.load()
        hasRestoredSession = true
        return session
    }

    func accessToken() async -> String? {
        if !hasRestoredSession {
            session = try? await store.load()
            hasRestoredSession = true
        }
        return session?.tokens.accessToken
    }

    func currentSession() async throws -> AuthSession? {
        try await restoreSession()
    }

    func save(_ session: AuthSession) async throws {
        try await store.save(session)
        self.session = session
        hasRestoredSession = true
    }

    func clear() async {
        try? await store.clear()
        session = nil
        hasRestoredSession = true
    }

    func refreshAccessToken() async throws -> String {
        if let refreshTask {
            return try await refreshTask.value.tokens.accessToken
        }

        guard let currentSession = try await restoreSession() else {
            throw AuthenticationError.invalidSession
        }

        let authenticationAPI = self.authenticationAPI
        let refreshToken = currentSession.tokens.refreshToken
        let task = Task<AuthSession, Error> {
            try await authenticationAPI.refresh(refreshToken: refreshToken)
        }
        refreshTask = task

        do {
            let refreshedSession = try await task.value
            try await store.save(refreshedSession)
            session = refreshedSession
            refreshTask = nil
            return refreshedSession.tokens.accessToken
        } catch {
            refreshTask = nil
            try? await store.clear()
            session = nil
            hasRestoredSession = true
            await invalidationHandler?()
            throw AuthenticationError.sessionExpired
        }
    }
}
