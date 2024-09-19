//
//  ObserveMangaUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 15/9/2024.
//

import Foundation
import RealmSwift

protocol ObserveMangaUseCase {
    func execute(manga: Manga, callback: @escaping (MangaEvent) -> Void) async -> NotificationToken?
}

final class ObserveMangaImpl: ObserveMangaUseCase {
    private let repo: MangaRepository
    
    init(repo: MangaRepository) {
        self.repo = repo
    }
    
    func execute(manga: Manga, callback: @escaping (MangaEvent) -> Void) async -> NotificationToken? {
        return await repo.observeManga(manga: manga, callback: callback)
    }
}
