//
//  FavoriteView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-25.
//

import SwiftUI

@MainActor
final class FavoriteViewModel: ObservableObject {
    
    @Published private(set) var favoriteProducts: [UserFavoriteProduct] = []
    
    func getFavoriteProducts() {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            let favoriteProducts = try await UserManager.shared.getAllUserFavoriteProducts(authDataResult.uid)
            self.favoriteProducts = favoriteProducts
        }
    }
    
    func removeFromFavorites(_ favoriteProductId: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try? await UserManager.shared.removeUserFavoriteProduct(userId: authDataResult.uid, favoriteProductId: favoriteProductId)
            getFavoriteProducts()
        }
    }
}

struct FavoriteView: View {

    @StateObject private var vm = FavoriteViewModel()
    
    var body: some View {
        List {
            ForEach(vm.favoriteProducts) { favoriteProduct in
                ProductCellBuilder(productId: favoriteProduct.productId)
                    .contextMenu {
                        Button {
                            vm.removeFromFavorites(favoriteProduct.id)
                        } label: {
                            Text("Remove from favorites")
                        }
                    }
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            vm.getFavoriteProducts()
        }
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        AdaptableNavigation {
            FavoriteView()
        }
    }
}
