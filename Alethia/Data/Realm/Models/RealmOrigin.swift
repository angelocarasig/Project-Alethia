//
//  RealmOrigin.swift
//  Illithia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation
import RealmSwift

final class RealmOrigin: Object {
    @Persisted(primaryKey: true) var id: String // Uses UUID().uuidString
    @Persisted var sourceId: String
    @Persisted var mangaId: String
    @Persisted(indexed: true) var slug: String
    @Persisted var updatedAt: Date
    @Persisted var createdAt: Date
    @Persisted var url: String
    @Persisted var chapters: List<RealmChapter>
    
    convenience init(_ origin: Origin) {
        self.init()
        
        id = origin.id
        sourceId = origin.sourceId
        mangaId = origin.mangaId
        slug = origin.slug
        updatedAt = origin.updatedAt
        createdAt = origin.createdAt
        url = origin.url
        chapters.append(objectsIn: origin.chapters.map { RealmChapter($0) })
    }
    
    func toDomain() -> Origin {
        return Origin(
            id: id,
            sourceId: sourceId,
            mangaId: mangaId,
            slug: slug,
            updatedAt: updatedAt,
            createdAt: createdAt,
            url: url,
            chapters: chapters.map { $0.toDomain() }
        )
    }
}
