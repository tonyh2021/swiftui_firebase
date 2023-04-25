//
//  Query+Ext.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

extension Query {
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        let document = try await getDocumentsWithSnapshot(as: type).items
        return document
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (items: [T], document: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let items = try snapshot.documents.map({ document in
            return try document.data(as: T.self)
        })
        
        return (items, snapshot.documents.last)
    }
    
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else {
            return self
        }
        return self
            .start(afterDocument: lastDocument)
    }
    
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return snapshot.count.intValue
    }

    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T : Decodable {
        let publisher = PassthroughSubject<[T], Error>()
        let listener = self.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                return
            }
            let items: [T] = documents.compactMap { documentSnapshot in
                return try? documentSnapshot.data(as: T.self)
            }
            publisher.send(items)
        }
        return (publisher.eraseToAnyPublisher(), listener)
    }
}
