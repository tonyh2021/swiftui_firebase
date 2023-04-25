//
//  FavoriteView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-25.
//

import SwiftUI

@MainActor
final class FavoriteViewModel: ObservableObject {
    
    @Published private(set) var products: [Product] = []
    
    func getFavorite() {
        
    }
}

struct FavoriteView: View {

    @StateObject private var vm = FavoriteViewModel()
    
    var body: some View {
        List {
            ForEach(vm.products) { product in
                ProductCell(product)
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            vm.getFavorite()
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
