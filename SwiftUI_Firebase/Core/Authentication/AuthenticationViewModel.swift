//
//  AuthenticationViewModel.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-20.
//

import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let token = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(token: token)
    }
    
    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let token = try await helper.startSignInWithAppleFlow()
        try await AuthenticationManager.shared.signInWithApple(token: token)
    }
    
    func signInAnonymously() async throws {
        let authDataResult = try await AuthenticationManager.shared.signInAnonymously()
        try await UserManager.shared.createNewUser(auth: authDataResult)
    }
}
