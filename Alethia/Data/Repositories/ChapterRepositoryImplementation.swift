//
//  ChapterRepositoryImplementation.swift
//  Alethia
//
//  Created by Angelo Carasig on 21/9/2024.
//

import Foundation
import RealmSwift

final class ChapterRepositoryImplementation {
    private let local: ChapterLocalDataSource
    private let remote: ChapterRemoteDataSource
    
    init(local: ChapterLocalDataSource, remote: ChapterRemoteDataSource) {
        self.local = local
        self.remote = remote
    }
}

extension ChapterRepositoryImplementation: ChapterRepository {
    func getChapterReferer(_ chapter: Chapter) async -> String {
        // Try fetching from local. If can't be found, fetch from remote.
        do {
            return try await local.getChapterReferer(chapter)
        }
        catch {
            return await remote.getChapterReferer(chapter)
        }
    }
    
    func getNextChapter(chapter: Chapter, origins: [Origin]) async throws -> Chapter? {
        return try await local.getNextChapter(chapter: chapter, origins: origins)
    }
    
    func getPreviousChapter(chapter: Chapter, origins: [Origin]) async throws -> Chapter? {
        return try await local.getPreviousChapter(chapter: chapter, origins: origins)
    }
}
