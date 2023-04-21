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
                settingNavigation
            }
        }
        .onAppear {
            let user = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = user == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            navigation
        }
    }
}

extension RootView {
    
    @ViewBuilder
    var settingNavigation: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ProfileView(showSignInView: $showSignInView)
            }
        } else {
            NavigationView {
                ProfileView(showSignInView: $showSignInView)
            }
        }
    }
    
    @ViewBuilder
    var navigation: some View {
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
