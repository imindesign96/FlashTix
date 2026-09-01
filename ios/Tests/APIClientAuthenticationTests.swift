import Foundation
import XCTest
@testable import FlashTix

final class APIClientAuthenticationTests: XCTestCase {
    func test_unauthorizedRequestRefreshesAndRetriesOnce() async throws {
        let initialSession = makeSession(accessToken: "expired-access", refreshToken: "old-refresh")
        let refreshedSession = makeSession(accessToken: "fresh-access", refreshToken: "new-refresh")
        let store = InMemorySessionStore(session: initialSession)
        let authenticationAPI = AuthenticationAPIStub(refreshResult: .success(refreshedSession))
        let tokenManager = TokenManager(store: store, authenticationAPI: authenticationAPI)
        let transport = ProtectedResourceTransport()
        let client = APIClient(
            baseURL: URL(string: "https://example.test")!,
            transport: transport,
            tokenManager: tokenManager
        )

        let response: TestResponse = try await client.get("protected")

        let authorizationHeaders = await transport.authorizationHeaders
        let refreshCallCount = await authenticationAPI.refreshCallCount
        XCTAssertEqual(response, TestResponse(value: "ok"))
        XCTAssertEqual(
            authorizationHeaders,
            ["Bearer expired-access", "Bearer fresh-access"]
        )
        XCTAssertEqual(refreshCallCount, 1)
    }
}

private struct TestResponse: Codable, Equatable, Sendable {
    let value: String
}

private actor ProtectedResourceTransport: HTTPTransport {
    private(set) var authorizationHeaders: [String] = []

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let authorization = request.value(forHTTPHeaderField: "Authorization") ?? ""
        authorizationHeaders.append(authorization)

        if authorization == "Bearer fresh-access" {
            let data = try JSONEncoder().encode(TestResponse(value: "ok"))
            return (data, response(for: request, statusCode: 200))
        }
        return (Data(), response(for: request, statusCode: 401))
    }

    private func response(for request: URLRequest, statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}
