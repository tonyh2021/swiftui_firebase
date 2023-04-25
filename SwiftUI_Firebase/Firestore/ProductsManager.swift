//
//  ProductsManager.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ProductsManager {
    
    static let shared = ProductsManager()
    
    private init() {}
    
    private let productCollection = Firestore.firestore().collection("products")
    
    private func productDocument(_ productId: String) -> DocumentReference {
        productCollection.document(productId)
    }
    
    func uploadProduct(product: Product) async throws {
        try productDocument(String(product.id)).setData(from: product, merge: false)
    }
    
    func getProduct(productId: Int) async throws -> Product {
        try await productDocument(String(productId)).getDocument(as: Product.self)
    }
    
//    private func getAllProducts() async throws -> [Product] {
//        try await productCollection
//            .getDocuments(as: Product.self)
//    }
//
//    private func getAllProductsSortedByPrice(descending: Bool) async throws -> [Product] {
//        try await productCollection
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
//            .getDocuments(as: Product.self)
//    }
//
//    private func getAllProductsForCategory(_ category: String) async throws -> [Product] {
//        try await productCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .getDocuments(as: Product.self)
//    }
//
//    private func getAllProductsByPrice(descending: Bool, category: String) async throws -> [Product] {
//        try await productCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
//            .getDocuments(as: Product.self)
//    }
    
    private func getAllProductsQuery() -> Query {
        productCollection
    }
    
    private func getAllProductsSortedByPriceQuery(descending: Bool) -> Query {
        productCollection
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
    }
    
    private func getAllProductsForCategoryQuery(_ category: String) -> Query {
        productCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
    }
    
    private func getAllProductsByPriceQuery(descending: Bool, category: String) -> Query {
        productCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
    }
    
    func getAllProducts(descending: Bool?, category: String?, count: Int, lastDocument: DocumentSnapshot?) async throws -> (items: [Product], document: DocumentSnapshot?) {
        var query: Query = getAllProductsQuery()
        if let descending, let category {
            query = getAllProductsByPriceQuery(descending: descending, category: category)
        } else if let descending {
            query = getAllProductsSortedByPriceQuery(descending: descending)
        } else if let category{
            query = getAllProductsForCategoryQuery(category)
        }
        if let lastDocument {
            return try await query
                .limit(to: count)
                .start(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Product.self)
        }
        return try await query
            .limit(to: count)
            .getDocumentsWithSnapshot(as: Product.self)
    }
    
    func getProductsByRating(count: Int, lastDocument: DocumentSnapshot?) async throws -> (items: [Product], document: DocumentSnapshot?) {
        return try await productCollection
            .order(by: Product.CodingKeys.price.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Product.self)
    }
    
    func getAllProductsCount() async throws -> Int {
        return try await productCollection.aggregateCount()
    }
}
