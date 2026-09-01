import XCTest
@testable import FlashTix

@MainActor
final class SessionControllerTests: XCTestCase {
    func test_loginPersistsSessionAndPublishesSignedInState() async throws {
        let session = makeSession()
        let store = InMemorySessionStore()
        let api = AuthenticationAPIStub(loginResult: .success(session))
        let tokenManager = TokenManager(store: store, authenticationAPI: api)
        let controller = SessionController(authenticationAPI: api, tokenManager: tokenManager)

        await controller.restore()
        await controller.login(email: "alex@example.com", password: "correct-horse")

        let storedSession = try await store.load()
        XCTAssertEqual(controller.state, .signedIn(session.user))
        XCTAssertEqual(storedSession, session)
    }

    func test_logoutClearsSessionAndPublishesSignedOutState() async throws {
        let session = makeSession()
        let store = InMemorySessionStore(session: session)
        let api = AuthenticationAPIStub()
        let tokenManager = TokenManager(store: store, authenticationAPI: api)
        let controller = SessionController(authenticationAPI: api, tokenManager: tokenManager)

        await controller.restore()
        await controller.logout()

        let storedSession = try await store.load()
        let logoutCallCount = await api.logoutCallCount
        XCTAssertEqual(controller.state, .signedOut)
        XCTAssertNil(storedSession)
        XCTAssertEqual(logoutCallCount, 1)
    }
}
