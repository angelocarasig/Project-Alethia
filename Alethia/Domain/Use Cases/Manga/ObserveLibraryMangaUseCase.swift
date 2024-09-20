//
//  ObserveLibraryMangaUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/9/2024.
//

import Foundation
import RealmSwift

protocol ObserveLibraryMangaUseCase {
    func execute(callback: @escaping ([Manga]) -> Void) async -> NotificationToken?
}

final class ObserveLibraryMangaImpl: ObserveLibraryMangaUseCase {
    private let repo: MangaRepository
    
    init(repo: MangaRepository) {
        self.repo = repo
    }
    
    func execute(callback: @escaping ([Manga]) -> Void) async -> NotificationToken? {
        return await repo.observeLibraryManga(callback: callback)
    }
}
