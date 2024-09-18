//
//  ViewModelFactory.swift
//  Alethia
//
//  Created by Angelo Carasig on 15/9/2024.
//

import Foundation

final class ViewModelFactory {
    static let shared = ViewModelFactory()
    
    private init() {}
    
    private let useCaseFactory = UseCaseFactory.shared
    
    private var mangaDetailsVMCache = [String: MangaDetailsViewModel]()
    
    func makeMangaDetailsViewModel(for manga: ListManga) -> MangaDetailsViewModel {
        if let cachedViewModel = mangaDetailsVMCache[manga.id] {
            return cachedViewModel
        }
        
        let viewModel = MangaDetailsViewModel(
            listManga: manga,
            fetchHostSourceMangaUseCase: useCaseFactory.makeFetchHostSourceMangaUseCase(),
            observeMangaUseCase: useCaseFactory.makeObserveMangaUseCase(),
            addMangaToLibraryUseCase: useCaseFactory.makeAddMangaToLibraryUseCase(),
            removeMangaFromLibraryUseCase: useCaseFactory.makeRemoveMangaFromLibraryUseCase()
        )
        
        mangaDetailsVMCache[manga.id] = viewModel
        return viewModel
    }
    
    func makeReaderViewModel(for chapter: Chapter) -> ReaderViewModel {
        return ReaderViewModel(
            fetchHostSourceMangaChapterContentUseCase: useCaseFactory.makeFetchHostSourceMangaChapterContentUseCase(), 
            chapter: chapter
        )
    }
}
