//
//  LibraryViewModel.swift
//  Alethia
//
//  Created by Angelo Carasig on 23/9/2024.
//

import Foundation
import RealmSwift

struct MangaQuery {
    let query: String
    let sort: MangaQuerySort
    let filters: MangaQueryFilter
}

struct MangaQuerySort {
    let sort: SortOption
    let direction: SortDirection
}

struct MangaQueryFilter {
    let status: Set<ContentStatus>
    let rating: Set<ContentRating>
}

@Observable
final class LibraryViewModel {
    // Published Properties
    var manga: [LibraryManga] = []
    var contentLoaded: Bool = false
    
    var searchQuery: String = "" {
        didSet {
            triggerQueryUpdate()
        }
    }
    var tabSelection: Int = 0
    
    // Modals
    var showingSortModal: Bool = false
    var showingFilterModal: Bool = false
    
    // Sort Options
    var selectedSortOption: SortOption = .addedAt { // Changed default to existing sort option
        didSet {
            triggerQueryUpdate()
        }
    }
    var selectedSortDirection: SortDirection = .descending {
        didSet {
            triggerQueryUpdate()
        }
    }
    
    // Filter Options
    var selectedContentStatus: Set<ContentStatus> = [] {
        didSet {
            triggerQueryUpdate()
        }
    }
    var selectedContentRating: Set<ContentRating> = [] {
        didSet {
            triggerQueryUpdate()
        }
    }
    
    // TODO: Dates
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
        
        observer = await executeQuery()
    }
    
    /// Triggers an update to the manga list by executing a new query.
    private func triggerQueryUpdate() {
        Task {
            // Cancel the previous observer if it exists
            observer?.invalidate()
            observer = await executeQuery()
        }
    }
    
    /// Executes the current query and observes the results.
    /// - Returns: A `NotificationToken` for the Realm observation.
    func executeQuery() async -> NotificationToken? {
        let search = self.searchQuery
        let sort = MangaQuerySort(sort: self.selectedSortOption, direction: self.selectedSortDirection)
        let filters = MangaQueryFilter(status: self.selectedContentStatus, rating: self.selectedContentRating)
        
        let query = MangaQuery(query: search, sort: sort, filters: filters)
        
        return await observeLibraryMangaUseCase.execute(query: query, limit: nil) { [weak self] results in
            guard let self = self else { return }
            self.manga = results
            self.contentLoaded = true
        }
    }
    
    func filteredManga(for status: ContentStatus) -> [LibraryManga] {
        return manga.filter { $0.contentStatus == status }
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
