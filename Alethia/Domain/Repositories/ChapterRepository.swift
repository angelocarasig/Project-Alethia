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
}
