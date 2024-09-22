//
//  RealmProvider.swift
//  Alethia
//
//  Created by Angelo Carasig on 8/9/2024.
//

import Foundation
import RealmSwift

final class RealmProvider {
    
    private var realm: Realm?
    
    func realm() async -> Realm? {
        if realm == nil {
            let config = Realm.Configuration(
                schemaVersion: 1,
                deleteRealmIfMigrationNeeded: false
            )
            realm = try? await Realm(configuration: config, actor: RealmActor.shared)
            
            print("Realm file location: \(realm?.configuration.fileURL?.absoluteString ?? "No file URL")")
        }
        
        return realm
    }
}
