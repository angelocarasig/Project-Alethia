//
//  RemoveMangaFromLibraryUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 15/9/2024.
//

import Foundation

protocol RemoveMangaFromLibraryUseCase {
    func execute(_ manga: Manga) async -> Void
}

final class RemoveMangaFromLibraryImpl: RemoveMangaFromLibraryUseCase {
    private let repo: MangaRepository
    
    init(repo: MangaRepository) {
        self.repo = repo
    }
    
    func execute(_ manga: Manga) async -> Void {
        await repo.removeMangaFromLibrary(manga)
    }
}
