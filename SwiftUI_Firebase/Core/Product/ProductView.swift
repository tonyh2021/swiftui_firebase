//
//  ProductView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-22.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class ProductViewModel: ObservableObject {
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var selectedFilterOption: FilterOption = .noFilter
    @Published private(set) var selectedCategoryOption: CategoryOption = .noCategory
    
    private var lastDocument: DocumentSnapshot? = nil
    private(set) var noMoreData: Bool = true
    
//    func getAllProducts() async throws {
//        products = try await ProductsManager.shared.getAllProducts(descending: selectedFilterOption?.priceDescending, category: selectedCategoryOption?.rawValue)
//    }
    
    func getProductsByRating() {
        Task {
            let (newProducts, lastDocument) = try await ProductsManager.shared.getProductsByRating(count: 4, lastDocument: lastDocument)
            products.append(contentsOf: newProducts)
            self.lastDocument = lastDocument
        }
    }
    
    func filterSelected(option: FilterOption) async throws {
        selectedFilterOption = option
        products = []
        lastDocument = nil
        getProducts()
    }
    
    func categorySelected(option: CategoryOption) async throws {
        selectedCategoryOption = option
        products = []
        lastDocument = nil
        getProducts()
        
    }
    
    func getProducts() {
//        print("lastDocument \(String(describing: lastDocument))")
        Task {
            let (newProducts, lastDocument) = try await ProductsManager.shared.getAllProducts(descending: selectedFilterOption.priceDescending, category: selectedCategoryOption.categoryOptionParameterKey, count: 10, lastDocument: lastDocument)
            noMoreData = newProducts.count == 0
            products.append(contentsOf: newProducts)
            if let lastDocument {
                self.lastDocument = lastDocument
            }
//            print("lastDocument \(String(describing: lastDocument))")
        }
    }
    
    func getProductsCount() {
        Task {
            let count = try await ProductsManager.shared.getAllProductsCount()
            print("All product count: \(count)")
        }
    }
    
    enum FilterOption: String, CaseIterable {
        case noFilter
        case priceHigh
        case priceLow
        
        var priceDescending: Bool? {
            switch self {
            case .noFilter: return nil
            case .priceHigh: return true
            case .priceLow: return false
            }
        }
        
        var filterValue: String {
            switch self {
            case .noFilter: return "None"
            case .priceHigh: return "Price High"
            case .priceLow: return "Price Low"
            }
        }
    }
    
    enum CategoryOption: String, CaseIterable {
        case noCategory
        case smartphones
        case laptops
        case fragrances
        
        var categoryOptionParameterKey: String? {
            switch self {
            case .noCategory: return nil
            case .smartphones, .laptops, .fragrances: return rawValue
            }
        }
        
        var categoryValue: String {
            switch self {
            case .noCategory: return "None"
            case .smartphones: return "Smart Phones"
            case .laptops: return "Laptops"
            case .fragrances: return "Fragrances"
            }
        }
    }
}

struct ProductView: View {
    
    @StateObject private var vm = ProductViewModel()
    
    var body: some View {
        List {
//            Button("Load More") {
//                vm.getProductsByRating()
//            }
            ForEach(vm.products) { product in
                ProductCell(product)
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
        NavigationView {
            ProductView()
        }
    }
}
