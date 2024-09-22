//
//  SourceContentViewModel.swift
//  Alethia
//
//  Created by Angelo Carasig on 14/9/2024.
//

import Foundation
import RealmSwift

@Observable
final class SourceContentViewModel {
    // Use Cases
    private var fetchHostSourceContentUseCase: FetchHostSourceContentUseCase
    private var observeSourceMangaUseCase: ObserveSourceMangaUseCase
    
    // To be displayed in SourceContent
    var rootResults: [SourceResult]
    
    /// When fetchedRootResults is set, re-init the observer
    private var fetchedRootResults: [SourceResult] {
        didSet {
            Task {
                await generateObserver()
            }
        }
    }
    
    // To be displayed in SourceContentGrid
    var pathResults: [SourceManga]
    
    /// When fetchedPathResults is set, re-init the observer
    private var fetchedPathResults: [SourceManga] {
        didSet {
            Task {
                await generateObserver()
            }
        }
    }
    
    // Observer
    private var observer: NotificationToken?
    
    // Host + Source
    var activeHost: Host
    var activeSource: Source
    
    // Root SourceContent Items
    var isLoadingRootContent: Bool // Loading indicator
    
    // Path SourceContentGrid Items
    /// This var is used to keep track on the the current SourceContentGrid. If the active path doesn't match we reset a lot of variables
    var activePath: String?
    
    /// When page changes, it should fetch path content
    var currentPage: Int {
        didSet {
            Task { await fetchPathContent(path: activePath ?? "") }
        }
    }
    var isLoadingPathContent: Bool // Loading indicator
    
    init(
        fetchHostSourceContentUseCase: FetchHostSourceContentUseCase,
        observeSourceMangaUseCase: ObserveSourceMangaUseCase,
        activeHost: Host,
        activeSource: Source
    ) {
        self.fetchHostSourceContentUseCase = fetchHostSourceContentUseCase
        self.observeSourceMangaUseCase = observeSourceMangaUseCase
        
        self.rootResults = []
        self.fetchedRootResults = []
        
        self.pathResults = []
        self.fetchedPathResults = []
        
        self.observer = nil
        
        self.activeHost = activeHost
        self.activeSource = activeSource
        
        self.isLoadingRootContent = false
        
        self.activePath = nil
        self.currentPage = 0
        self.isLoadingPathContent = false
    }
    
    deinit {
        observer?.invalidate()
    }
    
    // Use when root page loads
    func onRootPageLoad() {
        // Case where navigating to this page from a different tab that sets active host back to nil
        ActiveHostManager.shared.setActiveHost(host: activeHost, source: activeSource)
        
        // Don't trigger if content already present
        guard rootResults.isEmpty else {
            print("Root Results already exist. Recreating observer and skipping...")
            Task {
                await generateObserver()
            }
            
            return
        }
        
        Task {
            await fetchRootContent()
        }
    }
    
    // Use when grid page loads
    func onGridPageLoad(path: String) {
        // If new path is different, reset content
        if self.activePath != path {
            self.activePath = path
            resetPathContent()
        }
        
        // Case where navigating to this page from a different tab that sets active host back to nil
        ActiveHostManager.shared.setActiveHost(host: activeHost, source: activeSource)
        
        // Don't trigger if content already present
        guard pathResults.isEmpty else {
            print("Grid Results already exist. Recreating observer and skipping...")
            Task {
                await generateObserver()
            }
            return
        }
        
        Task {
            await fetchPathContent(path: path)
        }
    }
    
    func generateObserver() async {
        // Invalidate and recreate
        self.observer?.invalidate()
        
        // Observer initialized passing in fetched results and checks if they exist in library
        // NotifToken updates when anything changes
        observer = await observeSourceMangaUseCase.execute(roots: fetchedRootResults, paths: fetchedPathResults) { updatedRoots, updatedPaths in
            self.rootResults = updatedRoots
            self.pathResults = updatedPaths
        }
    }
    
    func fetchRootContent() async {
        // Don't trigger if root content is already loading
        guard !isLoadingRootContent else { return }
        
        isLoadingRootContent = true
        
        await withTaskGroup(of: SourceResult?.self) { taskGroup in
            for (index, route) in activeSource.routes.enumerated() {
                taskGroup.addTask {
                    // Make API call
                    let result = try? await self.fetchHostSourceContentUseCase.execute(
                        host: self.activeHost,
                        source: self.activeSource,
                        path: route.path,
                        page: 0 // always page 0 for root content
                    )
                    
                    // return mapped result
                    return result.map { SourceResult(index: index, name: route.name, path: route.path, results: $0.map { SourceManga($0, inLibrary: false) }) }
                }
            }
            
            var results: [SourceResult] = []
            for await task in taskGroup {
                if let result = task { results.append(result) }
            }
            
            // Assign to results based on their order
            // No pagination in this result so we don't need to handle duplicates or paginated appending responses
            fetchedRootResults = results.sorted(by: { $0.index < $1.index })
            
            isLoadingRootContent = false
        }
    }
    
    func fetchPathContent(path: String) async {
        // Prevent from triggering if already loading
        guard !isLoadingPathContent else { return }
        
        isLoadingPathContent = true
        
        do {
            // Make API call
            let results = try await fetchHostSourceContentUseCase.execute(
                host: activeHost,
                source: activeSource,
                path: path,
                page: currentPage
            )
            
            // Just append to path results, duplicates assume it was updated more than once recently for instance
            fetchedPathResults.append(contentsOf: results.map { SourceManga($0, inLibrary: false) })
            
        } catch {
            print("Error fetching content for path: \(path), error: \(error.localizedDescription)")
        }
        
        isLoadingPathContent = false
    }
    
    func resetPathContent() {
        // Reset everything to init state
        currentPage = 0
        isLoadingPathContent = false
        fetchedPathResults = []
    }
}
