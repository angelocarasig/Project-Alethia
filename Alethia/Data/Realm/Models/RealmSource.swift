//
//  RealmSource.swift
//  Illithia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation
import RealmSwift

class RealmSource: Object, Identifiable {
    @Persisted var name: String
    @Persisted var path: String
    @Persisted var routes: List<RealmSourceRoute>
    @Persisted var enabled: Bool
    
    convenience init(_ sourceObject: Source) {
        self.init()
        self.name = sourceObject.name
        self.path = sourceObject.path
        self.routes.append(objectsIn: sourceObject.routes.map { RealmSourceRoute($0) })
        self.enabled = sourceObject.enabled
    }
    
    func toDomain() -> Source {
        return Source(
            // just needs to be unique in this case
            id: UUID().uuidString,
            name: name,
            path: path,
            routes: routes.map { $0.toDomain() },
            enabled: enabled
        )
    }
}
