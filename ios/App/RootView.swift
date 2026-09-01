import SwiftUI

struct RootView: View {
    private let eventRepository: any EventRepository
    @StateObject private var sessionController: SessionController

    init(environment: AppEnvironment) {
        eventRepository = environment.eventRepository
        _sessionController = StateObject(wrappedValue: environment.sessionController)
    }

    var body: some View {
        Group {
            switch sessionController.state {
            case .checking:
                ProgressView("Restoring session...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .signedOut:
                AuthenticationView(sessionController: sessionController)

            case .signedIn(let user):
                MainTabView(
                    repository: eventRepository,
                    user: user,
                    onLogout: { await sessionController.logout() }
                )
            }
        }
        .task {
            await sessionController.restore()
        }
    }
}

private struct MainTabView: View {
    let repository: any EventRepository
    let user: AuthenticatedUser
    let onLogout: () async -> Void

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(repository: repository)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            PlaceholderView(title: "Search", systemImage: "magnifyingglass")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            PlaceholderView(title: "Tickets", systemImage: "ticket.fill")
                .tabItem {
                    Label("Tickets", systemImage: "ticket.fill")
                }

            PlaceholderView(title: "Saved", systemImage: "heart.fill")
                .tabItem {
                    Label("Saved", systemImage: "heart.fill")
                }

            ProfileView(user: user, onLogout: onLogout)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(FlashTixColor.brandPink)
    }
}
