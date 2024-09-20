//
//  ChapterDTO.swift
//  Illithia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation

struct ChapterDTO: Decodable {
    let slug: String
    
    // NOTE: These values are created on init, not through API fetch
    let sourceId: String?
    let mangaSlug: String?
    let chapterNumber: Double
    let chapterTitle: String
    let author: String
    let date: Date
    
    func toDomain() -> Chapter {
        return Chapter(
            originId: "DETACHED ORIGIN ID",
            slug: slug,
            mangaSlug: "DETACHED MANGA SLUG",
            chapterNumber: chapterNumber,
            chapterTitle: chapterTitle,
            author: author,
            date: date
        )
    }
    
    func toDomain(mangaSlug: String, originId: String) -> Chapter {
        return Chapter(
            originId: originId,
            slug: slug,
            mangaSlug: mangaSlug,
            chapterNumber: chapterNumber,
            chapterTitle: chapterTitle,
            author: author,
            date: date
        )
    }
}
