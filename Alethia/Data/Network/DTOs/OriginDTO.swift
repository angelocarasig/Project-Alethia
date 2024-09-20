//
//  SourceDTO.swift
//  Illithia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation

struct SourceDTO: Decodable {
    let id: String
    let sourceId: String
    let mangaId: String
    let slug: String
    let updatedAt: Date
    let createdAt: Date
    let url: String
    let coverUrl: String
    let chapters: [ChapterDTO]

    func toDomain() -> Origin {
        return Origin(
            id: id,
            sourceId: sourceId,
            mangaId: mangaId,
            slug: slug,
            updatedAt: updatedAt,
            createdAt: createdAt,
            url: url,
            coverUrl: coverUrl,
            chapters: chapters.map { $0.toDomain() }
        )
    }
}
