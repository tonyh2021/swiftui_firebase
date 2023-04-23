//
//  ProductView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-22.
//

import SwiftUI

@MainActor
final class ProductViewModel: ObservableObject {
    
    @Published private(set) var products: [Product] = []
    
    func getAllProducts() async throws {
        products = try await ProductsManager.shared.getAllProducts()
    }
}

struct ProductView: View {
    
    @StateObject private var vm = ProductViewModel()
    
    var body: some View {
        List {
            ForEach(vm.products) { product in
                ProductCell(product)
            }
        }
        .navigationTitle("Products")
        .onAppear {
            Task {
                try? await vm.getAllProducts()
            }
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        ProductView()
    }
}
