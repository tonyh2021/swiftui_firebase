//
//  StorageManager.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-25.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    private var imagesReference: StorageReference {
        storage.child("images")
    }
    
    private func userReference(_ userId: String) -> StorageReference {
        storage.child("users").child(userId)
    }
    
    func getUrlForImage(path: String) async throws -> URL {
        try await Storage.storage().reference(withPath: path).downloadURL()
    }
    
//    func getData(userId: String, path: String) async throws -> Data {
//        try await storage.child(path).data(maxSize: 20 * 1024 * 1024)
//    }
    
    func saveImage(data: Data, userId: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"

        let result = try await userReference(userId).child("\(UUID().uuidString).jpeg").putDataAsync(data, metadata: meta)
        
        guard let path = result.path, let name = result.name else {
            throw URLError(.badServerResponse)
        }
        
        return (path, name)
    }
    
    func deleteImage(url: String) async throws {
        try await Storage.storage().reference(forURL: url).delete()
    }
}
