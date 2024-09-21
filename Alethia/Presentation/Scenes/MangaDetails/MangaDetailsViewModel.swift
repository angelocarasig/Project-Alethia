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
    
    // List of origins with their respective hosts/sources
    var originData: [OriginCellData] = []
    
    // On open we should fetch so that even if the active manga is in library,
    // the current active host/source may not be in its origins
    var newOriginData: OriginCellData? {
        didSet {
            Task {
                await mergeOriginData()
            }
        }
    }
    
    var inLibrary: Bool = false
    var sourcePresent: Bool = false
    var showAlert: Bool = false
    var isFullScreen: Bool = false
    
    var expandedSources: Bool = false
    var expandedTracking: Bool = false
    
    var fetchedManga: Manga? {
        didSet {
            Task {
                // Once fetched init the observer
                await generateObserver()
                
                // Only needs to be triggered once realistically
                await getOriginParents()
            }
        }
    }
    let listManga: ListManga
    private var observer: NotificationToken?
    
    private let observeMangaUseCase: ObserveMangaUseCase
    private let fetchHostSourceMangaUseCase: FetchHostSourceMangaUseCase
    private let fetchNewOriginDataUseCase: FetchNewOriginDataUseCase
    private let getOriginParentsUseCase: GetOriginParentsUseCase
    private let addMangaToLibraryUseCase: AddMangaToLibraryUseCase
    private let removeMangaFromLibraryUseCase: RemoveMangaFromLibraryUseCase
    private let addOriginToMangaOriginsUseCase: AddOriginToMangaOriginsUseCase
    
    init(
        listManga: ListManga,
        fetchHostSourceMangaUseCase: FetchHostSourceMangaUseCase,
        fetchNewOriginDataUseCase: FetchNewOriginDataUseCase,
        observeMangaUseCase: ObserveMangaUseCase,
        getOriginParentsUseCase: GetOriginParentsUseCase,
        addMangaToLibraryUseCase: AddMangaToLibraryUseCase,
        removeMangaFromLibraryUseCase: RemoveMangaFromLibraryUseCase,
        addOriginToMangaOriginsUseCase: AddOriginToMangaOriginsUseCase
    ) {
        self.listManga = listManga
        
        print("New MDVM for \(listManga.title)")
        
        self.observeMangaUseCase = observeMangaUseCase
        self.fetchHostSourceMangaUseCase = fetchHostSourceMangaUseCase
        self.fetchNewOriginDataUseCase = fetchNewOriginDataUseCase
        self.getOriginParentsUseCase = getOriginParentsUseCase
        self.addMangaToLibraryUseCase = addMangaToLibraryUseCase
        self.removeMangaFromLibraryUseCase = removeMangaFromLibraryUseCase
        self.addOriginToMangaOriginsUseCase = addOriginToMangaOriginsUseCase
    }
    
    deinit {
        print("De-initialized MDVM for \(listManga.title).")
        observer?.invalidate()
    }
    
    func onOpen() async throws {
        // TODO: On Appear check the current manga details (manga details from source tabs chapters are showing in a manga from home tab
        try await fetchMangaDetails()
        try await fetchNewOriginData()
    }
    
    func onClose() {
        // Don't do anything for now
        
        //        observer?.invalidate()
        //        manga = nil
        //        // Don't set fetchedManga as nil or else it will retrigger observer generation
        //        inLibrary = false
        //        sourcePresent = false
        //
        //        // Kill yourself
        //        ViewModelFactory.shared.removeMangaDetailsViewModel(for: listManga.id)
    }
    
    /// Fetch manga details from host and source using the ActiveHostManager
    func fetchMangaDetails() async throws {
        fetchedManga = try await fetchHostSourceMangaUseCase.execute(
            host: ActiveHostManager.shared.getActiveHost(),
            source: ActiveHostManager.shared.getActiveSource(),
            listManga: listManga
        )
    }
    
    func fetchNewOriginData() async throws {
        guard let host = ActiveHostManager.shared.getActiveHost(),
              let source = ActiveHostManager.shared.getActiveSource()
        else {
            print("Won't be fetching new origin data. ActiveHostManager is nil.")
            return
        }
        
        newOriginData = try await fetchNewOriginDataUseCase.execute(
            host: host,
            source: source,
            slug: AlternativeHostManager.shared.findOriginalMapping(replacement: listManga.id) ?? listManga.id
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
                
            case .sourcePresent(let result, let newManga):
                print("Triggered source present callback with result: \(result)")
                self.sourcePresent = result
                // If updated manga is not empty update it
                if newManga != nil {
                    self.manga = newManga
                }
                
            case .errorOccurred(let result):
                print("Triggered error ocurred callback with result: \(result)")
            }
        }
        
        self.manga = fetchedManga
    }
    
    func getOriginParents() async {
        guard let manga = manga else { return }
        
        var results: [OriginCellData] = []
        
        // If manga contains just the origin it was fetched from
        if manga.origins.count == 1 && listManga.origin != .Local {
            // Only add the single origin
            let singleOrigin = manga.origins.first!
            let originCellData = OriginCellData(
                origin: singleOrigin,
                host: ActiveHostManager.shared.getActiveHost()!,
                source: ActiveHostManager.shared.getActiveSource()!
            )
            results.append(originCellData)
        } else {
            // For each origin in the manga, fetch its parent data
            for origin in manga.origins {
                if let parents = await getOriginParentsUseCase.execute(origin) {
                    let originCellData = OriginCellData(origin: origin, host: parents.0, source: parents.1)
                    results.append(originCellData)
                }
            }
        }
        
        self.originData = results
    }
    
    
    func addToLibrary() async {
        guard let manga = manga else { return }
        
        await addMangaToLibraryUseCase.execute(manga)
    }
    
    func removeFromLibrary() async {
        guard let manga = manga else { return }
        
        await removeMangaFromLibraryUseCase.execute(manga)
    }
    
    func addOrigin() async {
        guard let manga = manga,
              let origin = newOriginData?.origin
        else {return }
        
        await addOriginToMangaOriginsUseCase.execute(manga: manga, origin: origin)
    }
    
    private func mergeOriginData() async {
        guard let fetched = newOriginData,
              !originData.isEmpty
        else { return }
        
        if !originData.contains(where: { $0.origin.slug == fetched.origin.slug }) {
            originData.append(fetched)
        }
    }
}
