//
//  SourceContent.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import SwiftUI
import LucideIcons

struct SourceContent: View {
    // Use @Bindable not @State: https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro
    @Bindable var vm: SCVM
    
    private let useCaseFactory: UseCaseFactory = UseCaseFactory.shared
    
    var body: some View {
        print("Source Content Rerendered!")
        return VStack {
            if vm.isLoadingRootContent {
                ProgressView()
            } else {
                ContentView()
            }
        }
        .navigationTitle(vm.activeSource.name)
        .onAppear {
            vm.onRootPageLoad()
        }
    }
}

private extension SourceContent {
    @ViewBuilder
    func toMangaDetails(_ manga: ListManga) -> some View {
        MangaDetailsScreen(
            vm: MangaDetailsViewModel(
                listManga: manga,
                fetchHostSourceMangaUseCase: useCaseFactory.makeFetchHostSourceMangaUseCase(),
                observeMangaUseCase: useCaseFactory.makeObserveMangaUseCase(),
                addMangaToLibraryUseCase: useCaseFactory.makeAddMangaToLibraryUseCase()
            )
        )
    }
}

private extension SourceContent {
    func ContentView() -> some View {
        ScrollView {
            Spacer().frame(height: 12)
            
            ForEach(vm.rootResults) { result in
                VStack(alignment: .leading, spacing: 20) {
                    NavigationLink(
                        destination: SourceContentGrid(
                            title: result.name,
                            path: result.path,
                            vm: vm)
                    ) {
                        HStack {
                            Text(result.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.leading, 16)
                            Image(uiImage: Lucide.arrowRight)
                                .lucide()
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(result.results.prefix(20)) { manga in
                            let listManga = manga.toListManga()
                            MangaCard(item: listManga, destination: toMangaDetails(listManga), isInLibrary: manga.inLibrary)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

#Preview {
    let source1 = Source(
        id: UUID().uuidString,
        name: "Some enabled source",
        path: "/source1",
        routes: [],
        enabled: true
    )
    
    let host = Host(name: "Some Host", sources: [source1], baseUrl: "Some URL")
    
    let useCaseFactory = UseCaseFactory.shared
    
    return SourceContent(
        vm: SCVM(
            fetchHostSourceContentUseCase: useCaseFactory.makeFetchHostSourceContentUseCase(),
            observeSourceMangaUseCase: useCaseFactory.makeObserveSourceMangaUseCase(),
            activeHost: host,
            activeSource: source1
        ))
}
