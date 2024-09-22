//
//  ChapterRepository.swift
//  Alethia
//
//  Created by Angelo Carasig on 21/9/2024.
//

import Foundation

protocol ChapterRepository {
    func getChapterReferer(_ chapter: Chapter) async -> String
    func getNextChapter(chapter: Chapter, origins: [Origin]) async throws -> Chapter?
    func getPreviousChapter(chapter: Chapter, origins: [Origin]) async throws -> Chapter?
    
    // TODO
    /// func getReadEventsForManga(_ manga: Manga) async -> [ReadEvent]
    /// func getReadEventsForOrigin(_ origin: Origin) async -> [ReadEvent]
    /// func getMangaChaptersByPriority(_ manga: Manga, priority: ChapterPriority) async -> [Chapter]
    /// func markChapterAsRead(chapters: [Chapter], readStrategy: ReadStrategy) async throws -> Void
    /// func markChapterAsUnread(chapters: [Chapter], readStrategy: ReadStrategy) async throws -> Void
}
