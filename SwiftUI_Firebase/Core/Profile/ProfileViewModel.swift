//
//  ProfileViewModel.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-25.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func togglePremiumStatus() {
        guard let user else {
            return
        }
        let currentValue = user.isPremium ?? false
        Task {
            try await UserManager.shared.updateUserPremium(userId:user.userId, isPremium: !currentValue)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addUserPreference(preference: String) {
        guard let user else {
            return
        }
        Task {
            try await UserManager.shared.addUserPreference(userId:user.userId, preference:preference)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeUserPreference(preference: String) {
        guard let user else {
            return
        }
        Task {
            try await UserManager.shared.removeUserPreference(userId:user.userId, preference:preference)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addFavoriteMovie() {
        guard let user else {
            return
        }
        let movie = Movie(id: "1", title: "Avatar 2", isPopular: true)
        Task {
            try await UserManager.shared.addFavoriteMovie(userId:user.userId, movie:movie)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeFavoriteMovie() {
        guard let user else {
            return
        }
        Task {
            try await UserManager.shared.removeFavoriteMovie(userId:user.userId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}
