//
//  ProfileView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-20.
//

import SwiftUI

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
