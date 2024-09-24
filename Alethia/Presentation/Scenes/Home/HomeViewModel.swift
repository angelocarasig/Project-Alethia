//
//  HomeViewModel.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/9/2024.
//

import Foundation
import RealmSwift

@Observable
final class HomeViewModel {
    var manga: [LibraryManga] = []
    var recentlyAddedManga: [LibraryManga] = []
    var recentlyReadManga: [LibraryManga] = []
    var categoriedManga: [CategoriedManga] = []
    
    private var observer: NotificationToken?
    var contentLoaded: Bool = false
    
    private let observeLibraryMangaUseCase: ObserveLibraryMangaUseCase
    
    init(
        observeLibraryMangaUseCase: ObserveLibraryMangaUseCase
    )
    {
        self.observeLibraryMangaUseCase = observeLibraryMangaUseCase
        
        // Define user defaults here for now
        UserDefaultsHelper.shared.saveChapterPriority(ChapterPriority.firstSource)
    }
    
    deinit {
        observer?.invalidate()
    }
    
    func onOpen() async {
        // If content already loaded just return
        guard !contentLoaded else { return }
        
        observer = await observeLibraryMangaUseCase.execute(query: nil, limit: 10) { manga in
            self.manga = manga
            
            self.recentlyAddedManga = Array(manga.sorted(by: { $0.addedAt > $1.addedAt }).prefix(10))
            self.recentlyReadManga = Array(manga.shuffled().prefix(10).sorted(by: { $0.addedAt > $1.addedAt }))
            
            self.selectCategoriedManga(manga)
            
            self.contentLoaded = true
        }
    }
    
    func selectCategoriedManga(_ manga: [LibraryManga]) {
        // get random sample of 10 manga
        let mangaSample = manga.shuffled().prefix(10)
        
        // calculate tag frequencies
        let tagFrequency = mangaSample
            .flatMap { $0.tags }
            .reduce(into: [String: Int]()) { counts, tag in
                counts[tag, default: 0] += 1
            }
        
        // select 3/5 of most frequent tags
        let selectedTags = tagFrequency
            .sorted(by: { $0.value > $1.value })
            .prefix(5)
            .map { $0.key }
            .shuffled()
            .prefix(3)
        
        // create categories
        categoriedManga = selectedTags.map { tag in
            let filteredManga = manga.filter { $0.tags.contains(tag) }
                .shuffled()
                .prefix(10)
            
            return CategoriedManga(id: UUID().uuidString, category: tag, manga: Array(filteredManga))
        }
    }
    
}
