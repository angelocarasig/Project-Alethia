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
    @Bindable var vm: SCVM
    
    let useCaseFactory = UseCaseFactory.shared
    let dimensions = DimensionsCache.shared.dimensions
    
    var body: some View {
        print("Source Content Grid Loading with path: \(path)")
        
        return VStack {
            if vm.pathResults.isEmpty && vm.isLoadingPathContent {
                ProgressView()
            } else {
                ScrollView {
                    Spacer().frame(height: 20)
                    
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: dimensions.width), spacing: 0)],
                        spacing: 0
                    ) {
                        ForEach(vm.pathResults, id: \.id) { sourceManga in
                            let manga = sourceManga.toListManga()
                            
                            // TODO: not updating until onAppear again
                            MangaCard(item: manga, isInLibrary: sourceManga.inLibrary)
                                .onAppear {
                                    // TODO: block onLastItemAppeared() if results from recent is empty array
                                    // Or if no scroll action occurred? idk
                                    
                                    // If last one is in view, trigger a load more
                                    if sourceManga == vm.pathResults.last {
                                        onLastItemAppeared()
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    if vm.isLoadingPathContent {
                        ProgressView()
                            .padding(.vertical)
                    }
                }
                .refreshable {
                    onRefresh()
                }
            }
        }
        .onAppear {
            onAppear()
        }
        .navigationTitle(title)
    }
}

private extension SourceContentGrid {
    func onAppear() {
        vm.onGridPageLoad(path: path)
    }
    
    func onRefresh() {
        vm.resetPathContent()
    }
    
    func onLastItemAppeared() {
        vm.currentPage += 1
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
        vm: SCVM(
            fetchHostSourceContentUseCase: useCaseFactory.makeFetchHostSourceContentUseCase(),
            observeSourceMangaUseCase: useCaseFactory.makeObserveSourceMangaUseCase(),
            activeHost: host,
            activeSource: source1
        )
    )
}
