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
    var inLibrary: Bool = false
    var sourcePresent: Bool = false
    
    var fetchedManga: Manga? {
        didSet {
            Task {
                await generateObserver()
            }
        }
    }
    let listManga: ListManga
    private var observer: NotificationToken?
    
    private let observeMangaUseCase: ObserveMangaUseCase
    private let fetchHostSourceMangaUseCase: FetchHostSourceMangaUseCase
    private let addMangaToLibraryUseCase: AddMangaToLibraryUseCase
    
    init(
        listManga: ListManga,
        fetchHostSourceMangaUseCase: FetchHostSourceMangaUseCase,
        observeMangaUseCase: ObserveMangaUseCase,
        addMangaToLibraryUseCase: AddMangaToLibraryUseCase
    ) {
        self.listManga = listManga
        
        self.observeMangaUseCase = observeMangaUseCase
        self.fetchHostSourceMangaUseCase = fetchHostSourceMangaUseCase
        self.addMangaToLibraryUseCase = addMangaToLibraryUseCase
    }
    
    func onOpen() async throws {
        print("On Open Triggered.")
        try await fetchMangaDetails()
    }
    
    /// Fetch manga details from host and source using the ActiveHostManager
    func fetchMangaDetails() async throws {
        fetchedManga = try await fetchHostSourceMangaUseCase.execute(
            host: ActiveHostManager.shared.getActiveHost(),
            source: ActiveHostManager.shared.getActiveSource(),
            slug: listManga.id
        )
    }
    
    /// When fetchedManga is set, this function should be called as a side-effect
    private func generateObserver() async {
        guard let manga = self.fetchedManga else {
            print("Manga not properly initialized.")
            return
        }
        
        observer?.invalidate()
        
        observer = await observeMangaUseCase.execute(manga: manga) { callback in
            switch callback {
            case .inLibrary(let result):
                print("Triggered in library callback with result: \(result)")
                self.inLibrary = result
                
            case .sourcePresent(let result):
                print("Triggered source present callback with result: \(result)")
                self.sourcePresent = result
                
            case .errorOccurred(let result):
                print("Triggered error ocurred callback with result: \(result)")
            }
        }
        
        // After observer initialized, set manga to the fetched manga to be displayed in UI
        self.manga = fetchedManga
    }
    
    deinit {
        print("De-initialized.")
        observer?.invalidate()
    }
    
    func addToLibrary() async -> Bool {
        guard let manga = manga else { return false }

        // Perform the add operation
        let added = await addMangaToLibraryUseCase.execute(manga)

        if added {
            print("Manga added to library.")
        } else {
            print("Failed to add manga to library.")
        }

        // Ensure that `manga` is not modified or reset after this call
        return added
    }
    
    func removeFromLibrary() async -> Bool {
        // Implementation to remove manga from the library
        return true
    }
}
