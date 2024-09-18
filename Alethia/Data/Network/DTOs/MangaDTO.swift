//
//  MangaDTO.swift
//  Illithia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation

struct MangaDTO: Decodable {
    let sourceId: String
    let slug: String
    
    let title: String
    let alternativeTitles: [String]
    let author: String
    let artist: String
    let synopsis: String?
    
    let updatedAt: Date
    let createdAt: Date
    
    let contentStatus: String
    let contentRating: String
    
    let url: String
    let coverUrl: String
    
    let tags: [String]
    let chapters: [ChapterDTO]
    
    func toDomain() -> Manga {
        let mangaId = UUID().uuidString
        let sourceId = UUID().uuidString
        
        return Manga(
            id: mangaId,
            title: title,
            alternativeTitles: alternativeTitles,
            author: author,
            artist: artist,
            synopsis: synopsis ?? "No Description Available.",
            lastReadAt: updatedAt,
            addedAt: createdAt,
            contentRating: ContentRating(rawValue: contentRating) ?? .unknown,
            contentStatus: ContentStatus(rawValue: contentStatus) ?? .ongoing,
            coverUrl: coverUrl,
            tags: tags,
            groups: [],
            origins: [
                Origin(
                    id: sourceId,
                    sourceId: sourceId,
                    mangaId: mangaId,
                    slug: slug,
                    updatedAt: updatedAt,
                    createdAt: createdAt,
                    url: url,
                    chapters: chapters.map { $0.toDomain(mangaSlug: slug, sourceId: sourceId) }
                )
            ]
        )
    }
}
