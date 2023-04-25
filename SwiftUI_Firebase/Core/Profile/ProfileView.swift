//
//  ProfileView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-20.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @StateObject private var vm = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    @State private var isShowPhotoLibrary = false
    @State private var selectedImage: UIImage?
    
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
                
                Button {
                    isShowPhotoLibrary = true
                } label: {
                    Text("Select a photo")
                }
                
                if let photoUrl = vm.user?.photoUrl, let url = URL(string: photoUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                    
                    Button {
                        vm.deleteProfileImage()
                    } label: {
                        Text("Delete photo")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
        }
        .task {
            try? await vm.loadCurrentUser()
        }
        .onChange(of: selectedImage, perform: { newValue in
            if let selectedImage {
                vm.saveProfileImage(selectedImage)
            }
        })
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
