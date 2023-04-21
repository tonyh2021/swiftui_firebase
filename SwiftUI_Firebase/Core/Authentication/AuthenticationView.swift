//
//  AuthenticationView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-20.
//

import GoogleSignInSwift
import SwiftUI

struct AuthenticationView: View {
    @StateObject private var vm = AuthenticationViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            
            Button {
                Task {
                    do {
                        try await vm.signInAnonymously()
                        showSignInView = false
                    } catch {
                        print("Error: \(error)")
                    }
                }
            } label: {
                Text("Sign In Anonymously")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .frame(height: 55)

            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign In with Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await vm.signInGoogle()
                        showSignInView = false
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
                
            Button {
                Task {
                    do {
                        try await vm.signInApple()
                        showSignInView = false
                    } catch {
                        print("Error: \(error)")
                    }
                }
            } label: {
                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                    .allowsTightening(false)
            }
            .frame(height: 55)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                AuthenticationView(showSignInView: .constant(true))
            }
        } else {
            NavigationView {
                AuthenticationView(showSignInView: .constant(true))
            }
        }
    }
}
