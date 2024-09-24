//
//  RealmManga.swift
//  Illithia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation
import RealmSwift

final class RealmManga: Object {
    @Persisted(primaryKey: true) var id: String
    
    @Persisted(indexed: true) var title: String
    
    @Persisted var alternativeTitles: List<String>
    @Persisted(indexed: true) var normalizedTitles: String
    
    @Persisted var author: String
    @Persisted var artist: String
    @Persisted var synopsis: String
    
    @Persisted var addedAt: Date
    
    @Persisted var contentRating: ContentRating
    @Persisted var contentStatus: ContentStatus
    
    @Persisted var coverUrl: String
    
    @Persisted var tags: List<String>
    @Persisted var groups: List<RealmGroup>
    @Persisted var origins: List<RealmOrigin>
    
    convenience init(_ manga: Manga) {
        self.init()
        
        id = manga.id
        title = manga.title
        alternativeTitles.append(objectsIn: manga.alternativeTitles)
        author = manga.author
        artist = manga.artist
        synopsis = manga.synopsis
        addedAt = manga.addedAt
        contentRating = manga.contentRating
        contentStatus = manga.contentStatus
        coverUrl = manga.coverUrl
        tags.append(objectsIn: manga.tags)
        groups.append(objectsIn: manga.groups.map { RealmGroup($0) })
        origins.append(objectsIn: manga.origins.map { RealmOrigin($0) })
        
        // Compute and assign normalizedTitles
        normalizedTitles = computeNormalizedTitles()
    }
    
    private func computeNormalizedTitles() -> String {
        let allTitles = Set([title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)] +
                            alternativeTitles.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
        
        // Add pipe delimiter at the start and end to ensure exact match searchability
        return "|" + allTitles.joined(separator: "|") + "|"
    }
    
    func toLibraryManga() -> LibraryManga {
        return LibraryManga(
            id: id,
            title: title,
            synopsis: synopsis,
            coverUrl: coverUrl,
            origin: ListManga.Origin.Local,
            contentStatus: contentStatus,
            addedAt: addedAt,
            tags: Array(tags)
        )
    }
    
    func toListManga() -> ListManga {
        return ListManga(id: id, title: title, coverUrl: coverUrl, origin: ListManga.Origin.Local)
    }
    
    func toDomain() -> Manga {
        return Manga(
            id: id,
            title: title,
            alternativeTitles: Array(alternativeTitles),
            author: author,
            artist: artist,
            synopsis: synopsis,
            addedAt: addedAt,
            contentRating: contentRating,
            contentStatus: contentStatus,
            coverUrl: coverUrl,
            tags: Array(tags),
            groups: groups.map { $0.toDomain() },
            origins: origins.map { $0.toDomain() }
        )
    }
}
