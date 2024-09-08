//
//  RealmHost.swift
//  Illithia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation
import RealmSwift

final class RealmHost: Object, Identifiable {
    @Persisted(primaryKey: true) var name: String
    @Persisted var sources: List<RealmSource>
    @Persisted var baseUrl: String
    
    convenience init(_ repository: Host) {
        self.init()
        self.name = repository.name
        self.baseUrl = repository.baseUrl
        self.sources.append(objectsIn: repository.sources.map { RealmSource($0) })
    }
    
    func toDomain() -> Host {
        return Host(
            name: name,
            sources: sources.map { $0.toDomain() },
            baseUrl: baseUrl
        )
    }
}
