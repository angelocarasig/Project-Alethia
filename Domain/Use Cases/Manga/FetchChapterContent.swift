//
//  FetchChapterContent.swift
//  Alethia
//
//  Created by Angelo Carasig on 19/9/2024.
//

import Foundation

protocol FetchChapterContentUseCase {
    func execute(_ chapter: Chapter) async throws -> [URL]
}

final class FetchChapterContentImpl: FetchChapterContentUseCase {
    let repo: MangaRepository
    
    init(repo: MangaRepository) {
        self.repo = repo
    }
    
    func execute(_ chapter: Chapter) async throws -> [URL] {
        return try await repo.fetchChapterContent(chapter)
    }
}
