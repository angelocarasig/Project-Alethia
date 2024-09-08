//
//  SourceContentGrid.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import SwiftUI

struct SourceContentGrid: View {
    let title: String
    let path: String
    @ObservedObject var vm: SourceContentViewModel
    
    let useCaseFactory = UseCaseFactory.shared
    let dimensions = DimensionsCache.shared.dimensions
    
    var body: some View {
        VStack {
            if vm.isFetchingPathContent {
                ProgressView()
            } else {
                ScrollView {
                    Spacer().frame(height: 20)
                    
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: dimensions.width), spacing: 0)],
                        spacing: 0
                    ) {
                        ForEach(vm.specificRouteResults, id: \.id) { sourceManga in
                            let manga = sourceManga.toListManga()
                            
                            MangaCard(item: manga, destination: toMangaDetails(manga))
                                .onAppear {
                                    // If last one is in view, trigger a load more
                                    if sourceManga == vm.specificRouteResults.last {
                                        onLastItemAppeared()
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    if vm.isFetchingNextPage {
                        ProgressView()
                            .padding(.vertical)
                    }
                }
                .refreshable {
                    onRefresh()
                }
                
                .onAppear {
                    onAppear()
                }
            }
        }
        .navigationTitle(title)
    }
}

private extension SourceContentGrid {
    @ViewBuilder
    func toMangaDetails(_ manga: ListManga) -> some View {
        MangaDetailsScreen(
            vm: MangaDetailsViewModel(
                listManga: manga,
                observer: useCaseFactory.makeObserveMangaDbChangesUseCase(),
                fetchHostSourceManga: useCaseFactory.makeFetchHostSourceMangaUseCase(),
                addMangaToLibrary: useCaseFactory.makeAddMangaToLibraryUseCase()
            )
        )
    }
}

private extension SourceContentGrid {
    func onAppear() {
        print("On Appear")
        
        Task {
            if path != vm.specificRoutePath || !vm.specificHasLoaded {
                do {
                    try await vm.fetchPathContent(path: path)
                } catch {
                    print("Error fetching path content: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func onRefresh() {
        print("On Refresh")
        Task {
            vm.refreshPage()
            do {
                try await vm.fetchPathContent(path: path)
            } catch {
                print("Error fetching path content: \(error.localizedDescription)")
            }
        }
    }
    
    func onLastItemAppeared() {
        print("Last Item Appeared")
        Task {
            if !vm.isFetchingNextPage {
                vm.incrementPage()
                
                do {
                    try await vm.fetchNextPageContent()
                } catch {
                    print("Error fetching next page: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    let useCaseFactory = UseCaseFactory.shared
    
    let source1 = Source(
        id: UUID().uuidString,
        name: "Some Source",
        path: "/some_path",
        routes: [],
        enabled: true
    )
    
    let host = Host(
        name: "Some Host",
        sources: [source1],
        baseUrl: "https://some.host"
    )
    
    return SourceContentGrid(
        title: "Some Title",
        path: "Some Path",
        vm: SourceContentViewModel(
            observeMangaIds: useCaseFactory.makeObserveMangaIdsUseCase(),
            fetchHostSourceContent: useCaseFactory.makeFetchHostSourceContentUseCase(),
            activeHost: host,
            activeSource: source1
        )
    )
}
