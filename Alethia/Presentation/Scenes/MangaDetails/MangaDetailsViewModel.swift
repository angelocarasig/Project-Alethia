//
//  MangaDetailsViewModel.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import RealmSwift
import SwiftUI

@Observable
final class MangaDetailsViewModel {
    var manga: Manga?
    var inLibrary: Bool = false
    var sourcePresent: Bool = false
    var showAlert: Bool = false
    var isFullScreen: Bool = false
    
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
    private let removeMangaFromLibraryUseCase: RemoveMangaFromLibraryUseCase
    
    init(
        listManga: ListManga,
        fetchHostSourceMangaUseCase: FetchHostSourceMangaUseCase,
        observeMangaUseCase: ObserveMangaUseCase,
        addMangaToLibraryUseCase: AddMangaToLibraryUseCase,
        removeMangaFromLibraryUseCase: RemoveMangaFromLibraryUseCase
    ) {
        self.listManga = listManga
        
        print("New MDVM for \(listManga.title)")
        
        self.observeMangaUseCase = observeMangaUseCase
        self.fetchHostSourceMangaUseCase = fetchHostSourceMangaUseCase
        self.addMangaToLibraryUseCase = addMangaToLibraryUseCase
        self.removeMangaFromLibraryUseCase = removeMangaFromLibraryUseCase
    }
    
    func onOpen() async throws {
        // TODO: On Appear check the current manga details (manga details from source tabs chapters are showing in a manga from home tab
        try await fetchMangaDetails()
    }
    
    func onClose() {
        observer?.invalidate()
        observer = nil
        manga = nil
        fetchedManga = nil
        inLibrary = false
        sourcePresent = false
    }
    
    /// Fetch manga details from host and source using the ActiveHostManager
    func fetchMangaDetails() async throws {
        print("Fetching Manga Details for \(listManga.title)")
        fetchedManga = try await fetchHostSourceMangaUseCase.execute(
            host: ActiveHostManager.shared.getActiveHost(),
            source: ActiveHostManager.shared.getActiveSource(),
            listManga: listManga
        )
        
        if let fetchedManga = fetchedManga {
            print("Fetched Manga: \(fetchedManga.title), Chapters: \(fetchedManga.origins.first?.chapters.count ?? 0)")
            print("Last Chapter is Number \(fetchedManga.origins.first?.chapters.last?.chapterNumber) with title \(fetchedManga.origins.first?.chapters.last?.chapterTitle)")
        } else {
            print("Fetched Manga is nil for \(listManga.title)")
        }
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
    
    func addToLibrary() async {
        guard let manga = manga else { return }
        
        await addMangaToLibraryUseCase.execute(manga)
    }
    
    func removeFromLibrary() async {
        guard let manga = manga else { return }
        
        await removeMangaFromLibraryUseCase.execute(manga)
    }
}
