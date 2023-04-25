//
//  ProductCellBuilder.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-25.
//

import SwiftUI

struct ProductCellBuilder: View {
    
    let productId: Int
    @State private var product: Product? = nil
    
    var body: some View {
        ZStack {
            if let product {
                ProductCell(product)
            }
        }
        .task {
            product = try? await ProductsManager.shared.getProduct(productId: productId)
        }
    }
}

struct ProductCellBuilder_Previews: PreviewProvider {
    static var previews: some View {
        ProductCellBuilder(productId: 1)
    }
}
