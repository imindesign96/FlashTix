import SwiftUI

struct ProfileView: View {
    let user: AuthenticatedUser
    let onLogout: () async -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(FlashTixColor.brandGradient)
                            .frame(width: 52, height: 52)
                            .overlay {
                                Text(user.displayName.prefix(1).uppercased())
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                            }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(user.displayName)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section {
                    Button("Sign out", role: .destructive) {
                        Task { await onLogout() }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
