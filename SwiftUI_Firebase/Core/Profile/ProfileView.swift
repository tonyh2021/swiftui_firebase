//
//  ProfileView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-20.
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
}

struct ProfileView: View {
    
    @StateObject private var vm = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    private let preferenceOptions: [String] = ["Sports", "Movies", "Books"]
    
    private func preferenceSelected(_ text: String) -> Bool {
        vm.user?.preferences?.contains(text) == true
    }
    
    var body: some View {
        List {
            if let user = vm.user {
                Text("UserId: \(user.userId)")
                
                if let isAnonymous = user.isAnonymous {
                    Text("isAnonymous: \(isAnonymous.description)")
                }
                
                Button {
                    vm.togglePremiumStatus()
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
                
                VStack {
                    HStack {
                        ForEach(preferenceOptions, id: \.self) { item in
                            Button {
                                if (preferenceSelected(item)) {
                                    vm.removeUserPreference(preference: item)
                                } else {
                                    vm.addUserPreference(preference: item)
                                }
                            } label: {
                                Text(item)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(Color.white)
                            .font(.headline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(preferenceSelected(item) ? Color.green : Color.red)
                            .cornerRadius(6)
                        }
                    }
                    
                    Text("User preferences: \((user.preferences ?? []).joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    if user.favoriteMovie != nil {
                        vm.removeFavoriteMovie()
                    } else {
                        vm.addFavoriteMovie()
                    }
                } label: {
                    Text("Favorite Movie: \(user.favoriteMovie?.title ?? "")")
                }
            }
            
        }
        .onAppear {
            Task {
                try? await vm.loadCurrentUser()
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        AdaptableNavigation {
            ProfileView(showSignInView: .constant(false))
        }
    }
}
