//
//  SettingsViewModel.swift
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
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delete()
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
