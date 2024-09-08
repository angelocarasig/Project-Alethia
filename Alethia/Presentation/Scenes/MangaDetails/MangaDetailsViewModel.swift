//
//  MangaDetailsViewModel.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import Foundation
import RealmSwift

@Observable
final class MangaDetailsViewModel {
    var manga: Manga?
    private let listManga: ListManga
    private var observer: NotificationToken?
    
    private let observeMangaDbChanges: ObserveMangaDbChangesUseCase
    private let fetchHostSourceManga: FetchHostSourceMangaUseCase
    private let addMangaToLibrary: AddMangaToLibraryUseCase
    
    init(
        listManga: ListManga,
        observer: ObserveMangaDbChangesUseCase,
        fetchHostSourceManga: FetchHostSourceMangaUseCase,
        addMangaToLibrary: AddMangaToLibraryUseCase
    ) {
        self.listManga = listManga
        self.observeMangaDbChanges = observer
        self.fetchHostSourceManga = fetchHostSourceManga
        self.addMangaToLibrary = addMangaToLibrary
    }
    
    /// Fetch manga details from host and source using the ActiveHostManager
    func fetchMangaDetails() async throws {
        print("fetching \(listManga.title.prefix(10))...")
        manga = try await fetchHostSourceManga.execute(
            host: ActiveHostManager.shared.getActiveHost(),
            source: ActiveHostManager.shared.getActiveSource(),
            slug: listManga.id
        )
        
        print("Manga retrieved.")
    }
    
    func initObserver() async {
        print("initializing observer...")
        observer = await observeMangaDbChanges.execute()
        print("observer initialized...")
    }
    
    deinit {
        observer?.invalidate()
    }
    
    func addToLibrary() async -> Bool {
        guard let manga = manga else { return false }
        
        return await addMangaToLibrary.execute(manga)
    }
    
    func removeFromLibrary() async -> Bool {
        // Implementation to remove manga from the library
        return true
    }
}
