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
            fetchNewOriginDataUseCase: useCaseFactory.makeFetchNewOriginDataUseCase(),
            observeMangaUseCase: useCaseFactory.makeObserveMangaUseCase(),
            getOriginParentsUseCase: useCaseFactory.makeGetOriginParentsUseCase(),
            addMangaToLibraryUseCase: useCaseFactory.makeAddMangaToLibraryUseCase(),
            removeMangaFromLibraryUseCase: useCaseFactory.makeRemoveMangaFromLibraryUseCase(),
            addOriginToMangaOriginsUseCase: useCaseFactory.makeAddOriginToMangaOriginsUseCase()
        )
        
        MDVMCache.setObject(viewModel, forKey: manga.id as NSString)
        return viewModel
    }
    
    func removeMangaDetailsViewModel(for mangaID: String) {
        print("Killed MDVM with ID \(mangaID)")
        MDVMCache.removeObject(forKey: mangaID as NSString)
    }
    
    func makeReaderViewModel(chapter: Chapter, origins: [Origin]) -> ReaderViewModel {
        return ReaderViewModel(
            fetchChapterContentUseCase: useCaseFactory.makeFetchChapterContentUseCase(),
            getChapterRefererUseCase: useCaseFactory.makeGetChapterRefererUseCase(),
            getNextChapterUseCase: useCaseFactory.makeGetNextChapterUseCase(),
            getPreviousChapterUseCase: useCaseFactory.makeGetPreviousChapterUseCase(),
            chapter: chapter,
            origins: origins
        )
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            observeLibraryMangaUseCase: useCaseFactory.makeObserveLibraryMangaUseCase()
        )
    }
}
