//
//  TabbarView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-25.
//

import SwiftUI

struct TabbarView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        TabView {
            AdaptableNavigation {
                ProductView()
            }
            .tabItem {
                Image(systemName: "cart")
                Text("Products")
            }
            
            AdaptableNavigation {
                FavoriteView()
            }
            .tabItem {
                Image(systemName: "star.fill")
                Text("Favorites")
            }
            
            AdaptableNavigation {
                ProfileView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            
        }
    }
}

struct TabbarView_Previews: PreviewProvider {
    static var previews: some View {
        TabbarView(showSignInView: .constant(false))
    }
}
