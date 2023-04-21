//
//  SignInEmailViewModel.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-20.
//

import SwiftUI

@MainActor
class SignInEmailViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        try await AuthenticationManager.shared.signIn(email: email, password: password)
    }
}
