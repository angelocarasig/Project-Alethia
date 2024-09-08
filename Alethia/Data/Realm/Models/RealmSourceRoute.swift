//
//  RealmSourceRoute.swift
//  Illithia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation
import RealmSwift

class RealmSourceRoute: Object, Identifiable {
    @Persisted var name: String
    @Persisted var path: String
    
    convenience init(_ sourceRoute: SourceRoute) {
        self.init()
        self.name = sourceRoute.name
        self.path = sourceRoute.path
    }
    
    func toDomain() -> SourceRoute {
        return SourceRoute(
            name: name,
            path: path
        )
    }
}
