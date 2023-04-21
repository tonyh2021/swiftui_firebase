//
//  SignInEmailView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-20.
//

import SwiftUI

struct SignInEmailView: View {
    @StateObject private var vm = SignInEmailViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            TextField("Email...", text: $vm.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            SecureField("Password...", text: $vm.password).padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button {
                Task {
                    do {
                        try await vm.signUp()
                        showSignInView = false
                        return
                    } catch {
                        print("Error: \(error)")
                    }
                    
                    do {
                        try await vm.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print("Error: \(error)")
                    }
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In With Email")
    }
}

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        SignInEmailView(showSignInView: .constant(true))
    }
}
