//
//  LibraryViewModel.swift
//  Alethia
//
//  Created by Angelo Carasig on 23/9/2024.
//

import Foundation
import RealmSwift

@Observable
final class LibraryViewModel {
    // On any changes will return the computed response based on sort/filter/query
    var computedManga: [Manga] {
        var filteredManga = manga
        
        // Apply search query filter
        if !searchQuery.isEmpty {
            filteredManga = filteredManga.filter { manga in
                manga.title.localizedCaseInsensitiveContains(searchQuery) ||
                manga.alternativeTitles.contains { $0.localizedCaseInsensitiveContains(searchQuery) }
            }
        }
        
        // Apply content status filter
        if !selectedContentStatus.isEmpty {
            filteredManga = filteredManga.filter { selectedContentStatus.contains($0.contentStatus) }
        }
        
        // Apply content rating filter
        if !selectedContentRating.isEmpty {
            filteredManga = filteredManga.filter { selectedContentRating.contains($0.contentRating) }
        }
        
        // Apply sorting
        filteredManga.sort { (a: Manga, b: Manga) -> Bool in
            switch selectedSortOption {
            case .title:
                return selectedSortDirection == .ascending ? a.title < b.title : a.title > b.title
            case .addedAt:
                return selectedSortDirection == .ascending ? a.addedAt < b.addedAt : a.addedAt > b.addedAt
            case .lastReadAt:
                // TODO: Fix last read at
                return selectedSortDirection == .ascending ? a.addedAt < b.addedAt : a.addedAt > b.addedAt
            case .updatedAt:
                // TODO: Fix updated at
                return selectedSortDirection == .ascending ? a.addedAt < b.addedAt : a.addedAt > b.addedAt
            }
        }
        
        return filteredManga
    }
    
    var manga: [Manga] = []
    var contentLoaded: Bool = false
    
    var searchQuery: String = ""
    var tabSelection: Int = 0
    
    // Modals
    var showingSortModal: Bool = false
    var showingFilterModal: Bool = false
    
    // Sort Options
    var selectedSortOption: SortOption = .lastReadAt
    var selectedSortDirection: SortDirection = .descending
    
    // Filter Options
    var selectedContentStatus: Set<ContentStatus> = []
    var selectedContentRating: Set<ContentRating> = []
    var lastReadAt: Date = Date()
    var addedAt: Date = Date()
    var updatedAt: Date = Date()
    
    private var observer: NotificationToken?
    
    private var observeLibraryMangaUseCase: ObserveLibraryMangaUseCase
    
    init(
        observeLibraryMangaUseCase: ObserveLibraryMangaUseCase
    ) {
        self.observeLibraryMangaUseCase = observeLibraryMangaUseCase
    }
    
    func onOpen() async {
        guard !contentLoaded else { return }
        observer = await observeLibraryMangaUseCase.execute { manga in
            self.manga = manga
            self.contentLoaded = true
        }
    }
    
    func filteredManga(for status: ContentStatus) -> [Manga] {
        return computedManga.filter { $0.contentStatus == status }
    }
    
    func toggleSortModal() {
        showingSortModal.toggle()
    }
    
    func toggleFilterModal() {
        showingFilterModal.toggle()
    }
    
    func selectTab(_ index: Int) {
        tabSelection = index
    }
    
    func applySortOption(_ option: SortOption) {
        selectedSortOption = option
    }
    
    func applySortDirection(_ direction: SortDirection) {
        selectedSortDirection = direction
    }
    
    func updateSearchQuery(_ query: String) {
        searchQuery = query
    }
}

