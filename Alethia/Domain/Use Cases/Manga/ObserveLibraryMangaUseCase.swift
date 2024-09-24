//
//  ObserveLibraryMangaUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/9/2024.
//

import Foundation
import RealmSwift

protocol ObserveLibraryMangaUseCase {
    func execute(query: MangaQuery?, limit: Int?, callback: @escaping ([LibraryManga]) -> Void) async -> NotificationToken?
}

final class ObserveLibraryMangaImpl: ObserveLibraryMangaUseCase {
    private let repo: MangaRepository
    
    init(repo: MangaRepository) {
        self.repo = repo
    }
    
    func execute(query: MangaQuery? = nil, limit: Int? = 10, callback: @escaping ([LibraryManga]) -> Void) async -> NotificationToken? {
        return await repo.observeLibraryManga(query: query, limit: limit ?? 10, callback: callback)
    }
}
