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
    @Published var authUser: AuthDataResultModel? = nil

    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
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
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "123456789"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        let token = try await helper.signIn()
        authUser = try await AuthenticationManager.shared.linkGoogle(token: token)
    }
    
    func linkAppleAccount() async throws {
        let helper = SignInAppleHelper()
        let token = try await helper.startSignInWithAppleFlow()
        authUser = try await AuthenticationManager.shared.linkApple(token: token)
    }
    
    func linkEmailAccount() async throws {
        let email = "link@gmail.com"
        let password = "link123456789"
        authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
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
            
            if vm.authUser?.isAnonymous == true {
                anonymousSectionView
            }
            
        }
        .onAppear {
            vm.loadAuthProviders()
            vm.loadAuthUser()
        }
        .navigationTitle("Settings")
    }
}

extension SettingsView {
    
    private var anonymousSectionView: some View {
        Section {
            Button("Link Google Account") {
                Task {
                    do {
                        try await vm.linkGoogleAccount()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            Button("Link Apple Account") {
                Task {
                    do {
                        try await vm.linkAppleAccount()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            Button("Link Email Account") {
                Task {
                    do {
                        try await vm.linkEmailAccount()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        } header: {
            Text("Create Account")
        }
    }
    
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
