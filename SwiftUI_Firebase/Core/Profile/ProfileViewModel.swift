//
//  ProfileViewModel.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-25.
//

import SwiftUI

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
    
    func saveProfileImage(_ image: UIImage) {
        guard let user else {
            return
        }
        Task {
            guard let data = image.jpegData(compressionQuality: 1.0) else {
                return
            }
            let (path, _) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            try await UserManager.shared.updateUserPhotoUrl(userId: user.userId, url: url.absoluteString)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func deleteProfileImage() {
        guard let user, let url = user.photoUrl else {
            return
        }
        Task {
            try await StorageManager.shared.deleteImage(url: url)
            try await UserManager.shared.updateUserPhotoUrl(userId: user.userId, url: nil)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}
