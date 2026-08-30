import SwiftUI

struct RootView: View {
    let environment: AppEnvironment

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(repository: environment.eventRepository)
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

            PlaceholderView(title: "Profile", systemImage: "person.fill")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(FlashTixColor.brandPink)
    }
}
