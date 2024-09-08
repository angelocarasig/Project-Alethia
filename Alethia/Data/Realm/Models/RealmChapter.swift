//
//  RealmChapter.swift
//  Illithia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation
import RealmSwift

final class RealmChapter: Object {
    @Persisted(primaryKey: true) var slug: String
    @Persisted var originId: String
    @Persisted var mangaSlug: String
    @Persisted var chapterNumber: Double
    @Persisted var chapterTitle: String
    @Persisted var author: String
    @Persisted var date: Date
    
    convenience init(_ chapter: Chapter) {
        self.init()
        
        slug = chapter.slug
        originId = chapter.originId
        mangaSlug = chapter.mangaSlug
        chapterNumber = chapter.chapterNumber
        chapterTitle = chapter.chapterTitle
        author = chapter.author
        date = chapter.date
    }
    
    func toDomain() -> Chapter {
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
