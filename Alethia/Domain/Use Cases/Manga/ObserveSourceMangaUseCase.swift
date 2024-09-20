//
//  ObserveSourceMangaUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 14/9/2024.
//

import Foundation
import RealmSwift

protocol ObserveSourceMangaUseCase {
    func execute(
        roots: [SourceResult],
        paths: [SourceManga],
        callback: @escaping([SourceResult], [SourceManga]) -> Void
    ) async -> NotificationToken?
}

final class ObserveSourceMangaImpl: ObserveSourceMangaUseCase {
    private let repo: MangaRepository
    
    init(repo: MangaRepository) {
        self.repo = repo
    }
    
    func execute(
        roots: [SourceResult],
        paths: [SourceManga],
        callback: @escaping([SourceResult], [SourceManga]) -> Void
    ) async -> NotificationToken? 
    {
        return await repo.observeSourceManga(roots: roots, paths: paths, callback: callback)
    }
}
