//
//  FavoriteView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-25.
//

import SwiftUI

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
        .onFirstAppear {
            vm.addListenerForFavorite()
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
