//
//  SignInGoogleHelper.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-20.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let name: String?
    let email: String?
}

final class SignInGoogleHelper {
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        guard let idToken: String = result.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken: String = result.user.accessToken.tokenString
        let name = result.user.profile?.name
        let email = result.user.profile?.email

        let token = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, name: name, email: email)

        return token
    }
}
