import Foundation

@MainActor
final class SessionController: ObservableObject {
    enum State: Equatable {
        case checking
        case signedOut
        case signedIn(AuthenticatedUser)
    }

    @Published private(set) var state: State = .checking
    @Published private(set) var isSubmitting = false
    @Published private(set) var errorMessage: String?

    private let authenticationAPI: any AuthenticationServing
    private let tokenManager: TokenManager
    private var hasRestored = false

    init(authenticationAPI: any AuthenticationServing, tokenManager: TokenManager) {
        self.authenticationAPI = authenticationAPI
        self.tokenManager = tokenManager
    }

    func restore() async {
        guard !hasRestored else { return }
        hasRestored = true
        await tokenManager.setInvalidationHandler { [weak self] in
            await self?.sessionDidExpire()
        }

        do {
            if let session = try await tokenManager.restoreSession() {
                state = .signedIn(session.user)
            } else {
                state = .signedOut
            }
        } catch {
            await tokenManager.clear()
            state = .signedOut
        }
    }

    func login(email: String, password: String) async {
        await authenticate {
            try await authenticationAPI.login(email: email, password: password)
        }
    }

    func register(email: String, password: String, displayName: String) async {
        await authenticate {
            try await authenticationAPI.register(
                email: email,
                password: password,
                displayName: displayName
            )
        }
    }

    func logout() async {
        let refreshToken = try? await tokenManager.currentSession()?.tokens.refreshToken
        if let refreshToken {
            try? await authenticationAPI.logout(refreshToken: refreshToken)
        }
        await tokenManager.clear()
        errorMessage = nil
        state = .signedOut
    }

    func clearError() {
        errorMessage = nil
    }

    private func authenticate(operation: () async throws -> AuthSession) async {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            let session = try await operation()
            try await tokenManager.save(session)
            state = .signedIn(session.user)
        } catch let APIError.httpStatus(status) where status == 401 {
            errorMessage = "Email or password is incorrect."
        } catch {
            errorMessage = "Could not sign in. Check your connection and try again."
        }
    }

    private func sessionDidExpire() {
        errorMessage = "Your session expired. Please sign in again."
        state = .signedOut
    }
}
