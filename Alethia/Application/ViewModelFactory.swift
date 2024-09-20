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
    
    // NSCache benefit: https://developer.apple.com/documentation/foundation/nscache
    private let MDVMCache: NSCache<NSString, MangaDetailsViewModel> = {
        let cache = NSCache<NSString, MangaDetailsViewModel>()
        cache.countLimit = 100
        return cache
    }()

    
    func makeMangaDetailsViewModel(for manga: ListManga) -> MangaDetailsViewModel {
        if let cachedViewModel = MDVMCache.object(forKey: manga.id as NSString) {
            return cachedViewModel
        }
        
        let viewModel = MangaDetailsViewModel(
            listManga: manga,
            fetchHostSourceMangaUseCase: useCaseFactory.makeFetchHostSourceMangaUseCase(),
            observeMangaUseCase: useCaseFactory.makeObserveMangaUseCase(),
            addMangaToLibraryUseCase: useCaseFactory.makeAddMangaToLibraryUseCase(),
            removeMangaFromLibraryUseCase: useCaseFactory.makeRemoveMangaFromLibraryUseCase()
        )
        
        MDVMCache.setObject(viewModel, forKey: manga.id as NSString)
        return viewModel
    }
    
    func removeMangaDetailsViewModel(for mangaID: String) {
        print("Killed MDVM with ID \(mangaID)")
        MDVMCache.removeObject(forKey: mangaID as NSString)
    }
    
    func makeReaderViewModel(for chapter: Chapter) -> ReaderViewModel {
        return ReaderViewModel(
            fetchChapterContentUseCase: useCaseFactory.makeFetchChapterContentUseCase(),
            chapter: chapter
        )
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            observeLibraryMangaUseCase: useCaseFactory.makeObserveLibraryMangaUseCase()
        )
    }
}
