//
//  AddOriginToMangaOriginsUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 20/9/2024.
//

import Foundation

protocol AddOriginToMangaOriginsUseCase {
    func execute(manga: Manga, origin: Origin) async -> Void
}

final class AddOriginToMangaOriginsImpl: AddOriginToMangaOriginsUseCase {
    private let repo: MangaRepository
    
    init(repo: MangaRepository) {
        self.repo = repo
    }
    
    func execute(manga: Manga, origin: Origin) async {
        await repo.addOriginToMangaOrigins(manga: manga, origin: origin)
    }
}
