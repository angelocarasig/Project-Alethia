//
//  AddMangaToLibraryUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import Foundation

protocol AddMangaToLibraryUseCase {
    func execute(_ manga: Manga) async -> Void
}

final class AddMangaToLibaryImpl: AddMangaToLibraryUseCase {
    private let repo: MangaRepository
    
    init(repo: MangaRepository) {
        self.repo = repo
    }
    
    func execute(_ manga: Manga) async -> Void {
        await repo.addMangaToLibrary(manga)
    }
}
