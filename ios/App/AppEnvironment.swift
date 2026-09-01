import Foundation

@MainActor
struct AppEnvironment {
    let eventRepository: any EventRepository
    let sessionController: SessionController

    static func live(bundle: Bundle = .main) -> AppEnvironment {
        let rawURL = bundle.object(forInfoDictionaryKey: "FLASHTIX_API_BASE_URL") as? String
        let baseURL = URL(string: rawURL ?? "http://127.0.0.1:8080")!

        let authenticationClient = APIClient(baseURL: baseURL)
        let authenticationAPI = LiveAuthenticationAPI(client: authenticationClient)
        let sessionStore = KeychainSessionStore()
        let tokenManager = TokenManager(
            store: sessionStore,
            authenticationAPI: authenticationAPI
        )
        let authenticatedClient = APIClient(
            baseURL: baseURL,
            tokenManager: tokenManager
        )

        return AppEnvironment(
            eventRepository: LiveEventRepository(client: authenticatedClient),
            sessionController: SessionController(
                authenticationAPI: authenticationAPI,
                tokenManager: tokenManager
            )
        )
    }
}
