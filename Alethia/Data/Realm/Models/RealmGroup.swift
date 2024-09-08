//
//  RealmGroup.swift
//  Illithia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation
import RealmSwift

final class RealmGroup: Object {
    @Persisted(primaryKey: true) var name: String
    
    convenience init(_ group: Group) {
        self.init()
        name = group.name
    }
    
    func toDomain() -> Group {
        return Group(name: name)
    }
}
