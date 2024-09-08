//
//  SourceContentViewModel.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import Foundation
import RealmSwift

@Observable
final class SourceContentViewModel: ObservableObject {
    typealias SourceResult = SourceContentViewModel._SourceResult
    typealias SourceManga = SourceContentViewModel._SourceManga
    
    private let observeMangaIds: ObserveMangaIdsUseCase
    private let fetchHostSourceContent: FetchHostSourceContentUseCase
    
    fileprivate var observer: NotificationToken?
    
    var activeHost: Host
    var activeSource: Source
    
    var isFetchingRoutes: Bool = false
    var customRoutesResults: [SourceResult] = []
    var customHasLoaded: Bool = false
    
    var isFetchingPathContent: Bool = false
    var isFetchingNextPage: Bool = false
    var specificRoutePath: String?
    var specificRouteResults: [SourceManga] = []
    var page: Int = 0
    var specificHasLoaded: Bool = false
    
    init(
        observeMangaIds: ObserveMangaIdsUseCase,
        fetchHostSourceContent: FetchHostSourceContentUseCase,
        activeHost: Host,
        activeSource: Source
    ) {
        self.observeMangaIds = observeMangaIds
        self.fetchHostSourceContent = fetchHostSourceContent
        self.activeHost = activeHost
        self.activeSource = activeSource
    }
    
    func onAppear() {
        Task {
            await initializeObserver()
            await fetchAllRoutes()
        }
    }
    
    private func initializeObserver() async {
        await updateObserver()
    }
    
    private func updateObserver() async {
        observer?.invalidate()
        
        let allMangaIds = extractAllMangaIds()
        
        observer = await observeMangaIds.execute(ids: allMangaIds) { [weak self] mangaId, inLibrary in
            guard let self = self else { return }
            print("Updating library status~")
            self.updateLibraryStatus(for: mangaId, inLibrary: inLibrary)
        }
    }
    
    private func extractAllMangaIds() -> [String] {
        var ids: [String] = []
        
        ids.append(contentsOf: specificRouteResults.map { $0.title })
        
        for routeResult in customRoutesResults {
            ids.append(contentsOf: routeResult.results.map { $0.title })
        }
        
        return ids
    }
    
    func fetchAllRoutes() async {
        guard !customHasLoaded else { return }
        
        isFetchingRoutes = true
        customRoutesResults = []
        
        await withTaskGroup(of: SourceResult?.self) { taskGroup in
            for (index, sourceRoute) in activeSource.routes.enumerated() {
                taskGroup.addTask {
                    do {
                        let result = try await self.fetchHostSourceContent.execute(
                            host: self.activeHost,
                            source: self.activeSource,
                            path: sourceRoute.path,
                            page: 0
                        )
                        
                        let mappedResult = result.map { SourceManga($0, inLibrary: false) }
                        let sourceResult = SourceResult(index: index, name: sourceRoute.name, path: sourceRoute.path, results: mappedResult)
                        
                        return sourceResult
                    } catch {
                        print("Failed to fetch content for route: \(sourceRoute.name), error: \(error)")
                        return nil
                    }
                }
            }
            
            var fetchedResults: [SourceResult] = []
            
            for await taskResult in taskGroup {
                if let result = taskResult {
                    fetchedResults.append(result)
                }
            }
                        
            customRoutesResults = fetchedResults.sorted(by: { $0.index < $1.index })
        }
        
        for x in customRoutesResults {
            print("\(x.name) : \(x.results.count) count")
        }
        
        customHasLoaded = true
        isFetchingRoutes = false
        
        // Update observer to include new manga IDs
        await updateObserver()
    }
    
    func fetchPathContent(path: String) async throws {
        if specificRoutePath != path {
            specificRoutePath = path
            refreshPage()
        }
        
        guard !specificHasLoaded, !isFetchingPathContent else { return }
        
        isFetchingPathContent = true
        
        let resultContent = try await fetchHostSourceContent.execute(
            host: activeHost,
            source: activeSource,
            path: path,
            page: page
        )
        
        let mappedResults = resultContent.map { SourceManga($0, inLibrary: false) }
        specificRouteResults.append(contentsOf: mappedResults)
        specificHasLoaded = true
        isFetchingPathContent = false
        
        // Update observer to include new manga IDs
        await updateObserver()
    }
    
    func fetchNextPageContent() async throws {
        guard !isFetchingNextPage else { return }
        guard let path = specificRoutePath else { return }
        
        isFetchingNextPage = true
        
        let resultContent = try await fetchHostSourceContent.execute(
            host: activeHost,
            source: activeSource,
            path: path,
            page: page
        )
        
        let mappedResults = resultContent.map { SourceManga($0, inLibrary: false) }
        specificRouteResults.append(contentsOf: mappedResults)
        isFetchingNextPage = false
        
        await updateObserver()
    }
    
    func incrementPage() {
        page += 1
    }
    
    func refreshPage() {
        page = 0
        specificRouteResults = []
        specificHasLoaded = false
    }
    
    func specificDismissed() {
        page = 0
        specificRouteResults = []
        specificHasLoaded = false
    }
}

// MARK: - Observer Functionality

extension SourceContentViewModel {
    private func updateLibraryStatus(for mangaId: String, inLibrary: Bool) {
        print("Manga ID: \(mangaId)")
        if let index = specificRouteResults.firstIndex(where: { $0.title == mangaId }) {
            print("Updating \(specificRouteResults[index].title.prefix(10)) to \(inLibrary)")
            specificRouteResults[index].inLibrary = inLibrary
        
            // Don't return early here since the same manga could be both in a specific and custom route
        }
        
        // Update customRoutesResults
        for i in 0..<customRoutesResults.count {
            if let resultIndex = customRoutesResults[i].results.firstIndex(where: { $0.title == mangaId }) {
                print("Updating \(customRoutesResults[i].results[resultIndex].title.prefix(10)) to \(inLibrary)")
                customRoutesResults[i].results[resultIndex].inLibrary = inLibrary
            }
        }
    }
}
