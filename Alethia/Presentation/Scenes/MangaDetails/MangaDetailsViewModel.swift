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
    
    deinit {
        print("De-initialized.")
        observer?.invalidate()
    }
    
    func onOpen() async throws {
        // TODO: On Appear check the current manga details (manga details from source tabs chapters are showing in a manga from home tab
        try await fetchMangaDetails()
    }
    
    func onClose() {
        observer?.invalidate()
        manga = nil
        // Don't set fetchedManga as nil or else it will retrigger observer generation
        inLibrary = false
        sourcePresent = false
        
        // Kill yourself
        ViewModelFactory.shared.removeMangaDetailsViewModel(for: listManga.id)
    }
    
    /// Fetch manga details from host and source using the ActiveHostManager
    func fetchMangaDetails() async throws {
        fetchedManga = try await fetchHostSourceMangaUseCase.execute(
            host: ActiveHostManager.shared.getActiveHost(),
            source: ActiveHostManager.shared.getActiveSource(),
            listManga: listManga
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
    
    func addToLibrary() async {
        guard let manga = manga else { return }
        
        await addMangaToLibraryUseCase.execute(manga)
    }
    
    func removeFromLibrary() async {
        guard let manga = manga else { return }
        
        await removeMangaFromLibraryUseCase.execute(manga)
    }
}
