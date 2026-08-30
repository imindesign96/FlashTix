import Foundation

struct AppEnvironment: Sendable {
    let eventRepository: any EventRepository

    static func live(bundle: Bundle = .main) -> AppEnvironment {
        let rawURL = bundle.object(forInfoDictionaryKey: "FLASHTIX_API_BASE_URL") as? String
        let baseURL = URL(string: rawURL ?? "http://127.0.0.1:8080")!
        let client = APIClient(baseURL: baseURL)

        return AppEnvironment(
            eventRepository: LiveEventRepository(client: client)
        )
    }
}
