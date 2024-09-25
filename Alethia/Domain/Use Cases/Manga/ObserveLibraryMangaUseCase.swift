//
//  ObserveLibraryMangaUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/9/2024.
//

import Foundation
import RealmSwift

protocol ObserveLibraryMangaUseCase {
    func execute(query: MangaQuery?, callback: @escaping ([LibraryManga]) -> Void) async -> NotificationToken?
}

final class ObserveLibraryMangaImpl: ObserveLibraryMangaUseCase {
    private let repo: MangaRepository
    
    init(repo: MangaRepository) {
        self.repo = repo
    }
    
    func execute(query: MangaQuery? = nil, callback: @escaping ([LibraryManga]) -> Void) async -> NotificationToken? {
        return await repo.observeLibraryManga(query: query, callback: callback)
    }
}
