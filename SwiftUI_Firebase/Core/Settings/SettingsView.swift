//
//  SettingsView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-20.
//

import SwiftUI

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
            
            Button("Delete Account") {
                Task {
                    do {
                        try await vm.deleteAccount()
                        showSignInView = true
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            .foregroundColor(.red)
            
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
