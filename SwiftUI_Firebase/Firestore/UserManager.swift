//
//  UserManager.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

struct Movie: Codable {
    let id: String
    let title: String
    let isPopular: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case isPopular = "is_popular"
    }
}

struct DBUser: Codable {
    let userId: String
    let isAnonymous: Bool?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let isPremium: Bool?
    let preferences: [String]?
    let favoriteMovie: Movie?
    
    init(auth: AuthDataResultModel) {
        userId = auth.uid
        isAnonymous = auth.isAnonymous
        email = auth.email
        photoUrl = auth.email
        dateCreated = Date()
        isPremium = false
        preferences = []
        favoriteMovie = nil
    }
    
    init(userId: String, isAnonymous: Bool? = nil, email: String? = nil, photoUrl: String? = nil, dateCreated: Date? = nil, isPremium: Bool? = nil, preferences: [String]? = nil, favoriteMovie: Movie? = nil) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.preferences = preferences
        self.favoriteMovie = favoriteMovie
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        // If the backend is absurd😂
        case isPremium = "is_premium"
        case userIsPremium = "user_isPremium"
        
        case preferences = "preferences"
        case favoriteMovie = "favorite_movie"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
        try container.encodeIfPresent(self.preferences, forKey: .preferences)
        try container.encodeIfPresent(self.favoriteMovie, forKey: .favoriteMovie)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        var isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        if (isPremium == nil) {
            isPremium = try container.decodeIfPresent(Bool.self, forKey: .userIsPremium)
        }
        self.isPremium = isPremium
        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
        self.favoriteMovie = try container.decodeIfPresent(Movie.self, forKey: .favoriteMovie)
    }
}

final class UserManager {
    
    static let shared = UserManager()
    
    private init() {}
    
    private var userFavoriteProductsListener: ListenerRegistration? = nil
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(_ userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private func userFavoriteProductCollection(_ userId: String) -> CollectionReference {
        userDocument(userId).collection("favorite_products")
    }
    
    private func userFavoriteProductDocument(_ userId: String, favoriteProductId: String) -> DocumentReference {
        userFavoriteProductCollection(userId).document(favoriteProductId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(user.userId).setData(from: user, merge: false)
    }
    
    //    func createNewUser(auth: AuthDataResultModel) async throws {
    //        var userData: [String: Any] = [
    //            "user_id": auth.uid,
    //            "is_anonymous": auth.isAnonymous,
    //            "date_created": Timestamp(),
    //        ]
    //        if let email = auth.email {
    //            userData["email"] = email
    //        }
    //        if let photoUrl = auth.photoUrl {
    //            userData["photo_url"] = photoUrl
    //        }
    //
    //        try await userDocument(auth.uid).setData(userData, merge: false)
    //    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId).getDocument(as: DBUser.self)
    }
    
    //    func getUser(userId: String) async throws -> DBUser {
    //        let snapshot = try await userDocument(userId).getDocument()
    //        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
    //            throw URLError(.badServerResponse)
    //        }
    //
    //        let isAnonymous = data["is_anonymous"] as? Bool
    //        let email = data["email"] as? String
    //        let photoUrl = data["photo_url"] as? String
    //        let dateCreated = data["date_created"] as? Date
    //
    //        return DBUser(userId: userId, isAnonymous: isAnonymous, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
    //    }
    
    //    func updateUserPremium(user: DBUser) async throws {
    //        try userDocument(user.userId).setData(from: user, merge: true, encoder: encoder)
    //    }
    
    func updateUserPremium(userId: String, isPremium: Bool) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.isPremium.rawValue: isPremium
        ]
        try await userDocument(userId).updateData(data)
    }
    
    func addUserPreference(userId: String, preference: String) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.preferences.rawValue: FieldValue.arrayUnion([preference])
        ]
        try await userDocument(userId).updateData(data)
    }
    
    func removeUserPreference(userId: String, preference: String) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.preferences.rawValue: FieldValue.arrayRemove([preference])
        ]
        try await userDocument(userId).updateData(data)
    }
    
    func addFavoriteMovie(userId: String, movie: Movie) async throws {
        guard let movieData = try? encoder.encode(movie) else {
            throw URLError(.badURL)
        }
        let data: [String: Any] = [
            DBUser.CodingKeys.favoriteMovie.rawValue: movieData
        ]
        try await userDocument(userId).updateData(data)
    }
    
    func removeFavoriteMovie(userId: String) async throws {
        let data: [String: Any?] = [
            DBUser.CodingKeys.favoriteMovie.rawValue: nil
        ]
        try await userDocument(userId).updateData(data as [AnyHashable : Any])
    }
    
    
    func addUserFavoriteProduct(userId: String, productId: Int) async throws {
        let document = userFavoriteProductCollection(userId).document()
        let documentId = document.documentID
        
        let data: [String: Any] = [
            UserFavoriteProduct.CodingKeys.id.rawValue: documentId,
            UserFavoriteProduct.CodingKeys.productId.rawValue: productId,
            UserFavoriteProduct.CodingKeys.dateCreated.rawValue: Timestamp()
        ]
        try await document.setData(data, merge: false)
    }
    
    func removeUserFavoriteProduct(userId: String, favoriteProductId: String) async throws {
        try await userFavoriteProductDocument(userId, favoriteProductId: favoriteProductId).delete()
    }
    
//    func getAllUserFavoriteProducts(_ userId: String) async throws -> [UserFavoriteProduct] {
//        let collection = userFavoriteProductCollection(userId)
//        return try await collection.getDocuments(as: UserFavoriteProduct.self)
//    }
    
    func removeListenerForAllUserFavoriteProducts() {
        userFavoriteProductsListener?.remove()
    }
    
    func addListenerForAllUserFavoriteProducts(_ userId: String) -> AnyPublisher<[UserFavoriteProduct], Error> {
        let (publisher, listener) = userFavoriteProductCollection(userId).addSnapshotListener(as: UserFavoriteProduct.self)
        userFavoriteProductsListener = listener
        return publisher
    }
}

struct UserFavoriteProduct: Codable, Identifiable {
    let id: String
    let productId: Int
    let dateCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productId = "product_id"
        case dateCreated = "date_created"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.productId, forKey: .productId)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.productId = try container.decode(Int.self, forKey: .productId)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
}
