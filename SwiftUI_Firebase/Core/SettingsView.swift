//
//  SettingsView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-20.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []

    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUse = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUse.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "helloswiftui@gmail.com"
        try await  AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "123456789"
        try await  AuthenticationManager.shared.updatePassword(password: password)
    }
}

struct SettingsView: View {
    
    @StateObject private var vm = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Log Out") {
                Task {
                    do {
                        try vm.signOut()
                        showSignInView = true
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            
            if vm.authProviders.contains(.email) {
                emailSectionView
            }
        }
        .onAppear {
            vm.loadAuthProviders()
        }
        .navigationTitle("Settings")
    }
}

extension SettingsView {
    
    private var emailSectionView: some View {
        Section {
            Button("Reset Password") {
                Task {
                    do {
                        try await vm.resetPassword()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            Button("Update Password") {
                Task {
                    do {
                        try await vm.updatePassword()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            Button("Update Email") {
                Task {
                    do {
                        try await vm.updateEmail()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        } header: {
            Text("Email function")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSignInView: .constant(true))
    }
}
