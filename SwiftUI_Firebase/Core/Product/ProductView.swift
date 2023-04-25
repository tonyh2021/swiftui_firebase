//
//  ProductView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-22.
//

import SwiftUI
import FirebaseFirestore

struct ProductView: View {
    
    @StateObject private var vm = ProductViewModel()
    
    var body: some View {
        List {
//            Button("Load More") {
//                vm.getProductsByRating()
//            }
            ForEach(vm.products) { product in
                ProductCell(product)
                    .contextMenu {
                        Button {
                            vm.addUserFavoriteProduct(productId: product.id)
                        } label: {
                            Text("Add to favorites")
                        }
                    }
            }
            if !vm.noMoreData {
                ProgressView()
                    .onAppear {
                        vm.getProducts()
                    }
            }
        }
        .navigationTitle("Products")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu("Filter: \(vm.selectedFilterOption.filterValue)") {
                    ForEach(ProductViewModel.FilterOption.allCases, id: \.self) { option in
                        Button(option.filterValue) {
                            Task {
                                try? await vm.filterSelected(option:option)
                            }
                        }
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Category: \(vm.selectedCategoryOption.categoryValue)") {
                    ForEach(ProductViewModel.CategoryOption.allCases, id: \.self) { option in
                        Button(option.categoryValue) {
                            Task {
                                try? await vm.categorySelected(option:option)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            vm.getProductsCount()
            vm.getProducts()
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        AdaptableNavigation {
            ProductView()
        }
    }
}
