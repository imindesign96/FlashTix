import XCTest
@testable import FlashTix

final class TokenManagerTests: XCTestCase {
    func test_concurrentRefreshesShareOneOperation() async throws {
        let initialSession = makeSession(accessToken: "expired-access", refreshToken: "old-refresh")
        let refreshedSession = makeSession(accessToken: "fresh-access", refreshToken: "new-refresh")
        let store = InMemorySessionStore(session: initialSession)
        let api = AuthenticationAPIStub(
            refreshResult: .success(refreshedSession),
            refreshDelayNanoseconds: 50_000_000
        )
        let manager = TokenManager(store: store, authenticationAPI: api)

        let accessTokens = try await withThrowingTaskGroup(of: String.self) { group in
            for _ in 0..<20 {
                group.addTask {
                    try await manager.refreshAccessToken()
                }
            }

            var values: [String] = []
            for try await value in group {
                values.append(value)
            }
            return values
        }

        let refreshCallCount = await api.refreshCallCount
        let storedSession = try await store.load()
        XCTAssertEqual(refreshCallCount, 1)
        XCTAssertEqual(Set(accessTokens), ["fresh-access"])
        XCTAssertEqual(storedSession, refreshedSession)
    }

    func test_failedRefreshClearsStoredSession() async {
        let store = InMemorySessionStore(session: makeSession())
        let api = AuthenticationAPIStub(refreshResult: .failure(.rejected))
        let manager = TokenManager(store: store, authenticationAPI: api)

        do {
            _ = try await manager.refreshAccessToken()
            XCTFail("Expected refresh to fail")
        } catch {
            XCTAssertEqual(error as? AuthenticationError, .sessionExpired)
        }

        let storedSession = try? await store.load()
        XCTAssertNil(storedSession)
    }
}
