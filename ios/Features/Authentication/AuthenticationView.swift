import SwiftUI

struct AuthenticationView: View {
    private enum Mode: String, CaseIterable {
        case login = "Sign in"
        case register = "Create account"
    }

    @ObservedObject var sessionController: SessionController

    @State private var mode: Mode = .login
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case displayName
        case email
        case password
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                brandHeader
                modePicker
                form
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: mode) {
            sessionController.clearError()
            focusedField = mode == .register ? .displayName : .email
        }
    }

    private var brandHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(FlashTixColor.brandGradient)
                    .frame(width: 88, height: 88)
                Image(systemName: "ticket.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Text("FlashTix")
                    .font(.largeTitle.bold())
                Text("Find the moment. Keep the ticket.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var modePicker: some View {
        Picker("Authentication mode", selection: $mode) {
            ForEach(Mode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private var form: some View {
        VStack(spacing: 16) {
            if mode == .register {
                TextField("Display name", text: $displayName)
                    .textContentType(.name)
                    .focused($focusedField, equals: .displayName)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .email }
                    .textFieldStyle(AuthenticationTextFieldStyle())
            }

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.emailAddress)
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
                .textFieldStyle(AuthenticationTextFieldStyle())

            SecureField("Password", text: $password)
                .textContentType(mode == .register ? .newPassword : .password)
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit(submit)
                .textFieldStyle(AuthenticationTextFieldStyle())

            if let errorMessage = sessionController.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: submit) {
                Group {
                    if sessionController.isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(mode.rawValue)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(FlashTixColor.brandGradient)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .disabled(!canSubmit || sessionController.isSubmitting)
            .opacity(canSubmit ? 1 : 0.55)

            Text("Passwords must contain at least 8 characters.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var canSubmit: Bool {
        let validCredentials = email.contains("@") && password.count >= 8
        return mode == .login ? validCredentials : validCredentials && !displayName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submit() {
        guard canSubmit else { return }
        focusedField = nil
        Task {
            switch mode {
            case .login:
                await sessionController.login(email: email, password: password)
            case .register:
                await sessionController.register(
                    email: email,
                    password: password,
                    displayName: displayName
                )
            }
        }
    }
}

private struct AuthenticationTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
