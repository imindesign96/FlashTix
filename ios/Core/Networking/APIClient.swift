import Foundation

actor APIClient {
    private let baseURL: URL
    private let transport: any HTTPTransport
    private let tokenManager: TokenManager?
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        baseURL: URL,
        transport: any HTTPTransport = URLSessionTransport(),
        tokenManager: TokenManager? = nil
    ) {
        self.baseURL = baseURL
        self.transport = transport
        self.tokenManager = tokenManager

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    func get<Response: Decodable & Sendable>(
        _ path: String,
        as type: Response.Type = Response.self
    ) async throws -> Response {
        let request = try await makeRequest(path: path, method: "GET", body: Optional<String>.none)
        let data = try await perform(request, mayRefresh: true)
        return try decode(type, from: data)
    }

    func post<Body: Encodable & Sendable, Response: Decodable & Sendable>(
        _ path: String,
        body: Body,
        as type: Response.Type = Response.self
    ) async throws -> Response {
        let request = try await makeRequest(path: path, method: "POST", body: body)
        let data = try await perform(request, mayRefresh: true)
        return try decode(type, from: data)
    }

    func post<Body: Encodable & Sendable>(_ path: String, body: Body) async throws {
        let request = try await makeRequest(path: path, method: "POST", body: body)
        _ = try await perform(request, mayRefresh: true)
    }

    private func makeRequest<Body: Encodable>(
        path: String,
        method: String,
        body: Body?
    ) async throws -> URLRequest {
        let url = baseURL.appending(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.encodingFailed
            }
        }

        if let accessToken = await tokenManager?.accessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func perform(_ request: URLRequest, mayRefresh: Bool) async throws -> Data {
        let (data, response) = try await transport.data(for: request)
        try Task.checkCancellation()

        if response.statusCode == 401, mayRefresh, let tokenManager {
            let refreshedAccessToken = try await tokenManager.refreshAccessToken()
            try Task.checkCancellation()

            var retryRequest = request
            retryRequest.setValue(
                "Bearer \(refreshedAccessToken)",
                forHTTPHeaderField: "Authorization"
            )
            return try await perform(retryRequest, mayRefresh: false)
        }

        guard 200..<300 ~= response.statusCode else {
            throw APIError.httpStatus(response.statusCode)
        }
        return data
    }

    private func decode<Response: Decodable>(_ type: Response.Type, from data: Data) throws -> Response {
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
