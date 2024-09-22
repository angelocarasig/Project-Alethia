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
    var originData: [OriginCellData] = [] {
        didSet {
            print("Origin Data was set. Count \(originData.count)")
        }
    }
    
    // On open we should fetch so that even if the active manga is in library,
    // the current active host/source may not be in its origins
    var newOriginData: OriginCellData?
    
    var inLibrary: Bool = false
    var sourcePresent: Bool = false
    var showAlert: Bool = false
    var isFullScreen: Bool = false
    
    var expandedSources: Bool = false
    var expandedTracking: Bool = false
    
    var fetchedManga: Manga?
    
    // Inputs
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
        
        print("Init new MDVM for \(listManga.title)")
        
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
        try await fetchMangaDetails()
        try await fetchNewOriginData()
    }
    
    func onClose() { }
    
    /// Fetch returns either the local manga's details or a fresh one from remote
    func fetchMangaDetails() async throws {
        fetchedManga = try await fetchHostSourceMangaUseCase.execute(
            host: ActiveHostManager.shared.getActiveHost(),
            source: ActiveHostManager.shared.getActiveSource(),
            listManga: listManga
        )
        
        // Once fetched, first create an observer to listen for changes
        await generateObserver()
        
        //
        // First get all origins parents
        await getOriginParents()
        
        // Fetch new origin data if needed
        // If origins is non-empty empty and data was actually fetched,
        // trigger a merge side-effect from new origin data into the origindata array
        try await fetchNewOriginData()
    }
    
    func fetchNewOriginData() async {
        guard let host = ActiveHostManager.shared.getActiveHost(),
              let source = ActiveHostManager.shared.getActiveSource()
        else {
            print("Fetching New Origin Data: Won't be fetching new origin data. ActiveHostManager is nil.")
            return
        }
        
        do {
            newOriginData = try await fetchNewOriginDataUseCase.execute(
                host: host,
                source: source,
                slug: AlternativeHostManager.shared.findOriginalMapping(replacement: listManga.id) ?? listManga.id
            )
            
            if let newData = newOriginData {
                print("Received new origin data from \(newData.host.name)... Merging Origin Data...")
                await mergeOriginData()
            } else {
                print("Received new origin data is nil.")
            }
        } catch {
            print("Error fetching new origin data: \(error)")
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
        
        print("Get Origin Parents: Manga origins count is \(manga.origins.count)")
        print("Get Origin Parents: ListManga origin is \(listManga.origin == .Local ? "Local" : "Remote")")
        
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
        print("Merge Origin Data: Merging Origin Data...")
        guard let fetched = newOriginData,
              !originData.isEmpty
        else {
            print("Merge Origin Data: Origin Data is empty.")
            return
        }
        
        if !originData.contains(where: { $0.origin.slug == fetched.origin.slug }) {
            print("Merge Origin Data: Origin Data is appending origin from \(fetched.source.name)!")
            originData.append(fetched)
        }
    }
}
