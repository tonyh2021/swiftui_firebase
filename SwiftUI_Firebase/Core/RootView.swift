//
//  RootView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-20.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignInView {
                navigation
            }
        }
        .onAppear {
            let user = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = user == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            authenticationNavigation
        }
    }
}

extension RootView {
    
    @ViewBuilder
    var navigation: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ProductView()
//                ProfileView(showSignInView: $showSignInView)
            }
        } else {
            NavigationView {
                ProductView()
//                ProfileView(showSignInView: $showSignInView)
            }
        }
    }
    
    @ViewBuilder
    var authenticationNavigation: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        } else {
            NavigationView {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
