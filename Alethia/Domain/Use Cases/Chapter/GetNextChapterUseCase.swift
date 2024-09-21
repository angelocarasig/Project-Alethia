//
//  GetNextChapterUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 21/9/2024.
//

import Foundation

protocol GetNextChapterUseCase {
    func execute(chapter: Chapter, origins: [Origin]) async throws -> Chapter?
}

final class GetNextChapterImpl: GetNextChapterUseCase {
    private let repo: ChapterRepository
    
    init(repo: ChapterRepository) {
        self.repo = repo
    }
    
    func execute(chapter: Chapter, origins: [Origin]) async throws -> Chapter? {
        return try await repo.getNextChapter(chapter: chapter, origins: origins)
    }
}
