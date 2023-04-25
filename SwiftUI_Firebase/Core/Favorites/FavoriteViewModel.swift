//
//  FavoriteViewModel.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-25.
//

import Foundation
import Combine

@MainActor
final class FavoriteViewModel: ObservableObject {
    
    @Published private(set) var favoriteProducts: [UserFavoriteProduct] = []
    private var cancellables = Set<AnyCancellable>()
    
    func addListenerForFavorite() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else {
            return
        }
        UserManager.shared.addListenerForAllUserFavoriteProducts(authDataResult.uid).sink { completion in
            
        } receiveValue: { [weak self] products in
            self?.favoriteProducts = products
        }
        .store(in: &cancellables)
    }
    
    func removeFromFavorites(_ favoriteProductId: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try? await UserManager.shared.removeUserFavoriteProduct(userId: authDataResult.uid, favoriteProductId: favoriteProductId)
        }
    }
}
