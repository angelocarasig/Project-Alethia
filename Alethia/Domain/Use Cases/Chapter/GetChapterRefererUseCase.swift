//
//  GetChapterRefererUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 21/9/2024.
//

import Foundation

protocol GetChapterRefererUseCase {
    func execute(_ chapter: Chapter) async -> String
}

final class GetChapterRefererImpl: GetChapterRefererUseCase {
    private let repo: ChapterRepository
    
    init(repo: ChapterRepository) {
        self.repo = repo
    }
    
    func execute(_ chapter: Chapter) async -> String {
        return await repo.getChapterReferer(chapter)
    }
}
