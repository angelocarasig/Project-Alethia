//
//  MangaDetailsScreen.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import SwiftUI

struct MangaDetailsScreen: View {
    @Bindable var vm: MangaDetailsViewModel
    
    var body: some View {
        ZStack {
            if let manga = vm.manga {
                ContentView(manga)
            } else {
                ProgressView("Loading Manga...")
            }
        }
        .onAppear {
            Task {
                await vm.initObserver()
                try await vm.fetchMangaDetails()
            }
        }
    }
}

private extension MangaDetailsScreen {
    func addToLibrary() async {
        Task {
            await vm.addToLibrary()
        }
    }
    
    func removeFrom() async {
        print("removed from library")
    }
    
    @ViewBuilder
    func ContentView(_ manga: Manga) -> some View {
        Backdrop(coverUrl: URL(string: manga.coverUrl)!)
        
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    Spacer().frame(height: geometry.size.height / 3)
                    
                    TitleAuthorArtist(title: manga.title, author: manga.author, artist: manga.artist)
                    
                    Gap(12)
                    
                    ActionButtons(
                        manga: manga,
                        inLibrary: false,
                        addToLibrary: {await addToLibrary()},
                        removeFromLibrary: {await removeFrom()}
                    )
                    
                    Gap(12)
                    
                    MangaDetailsDescription(description: manga.synopsis)
                    
                    Gap(22)
                    
                    Tags(tags: manga.tags)
                    
                    Gap(22)
                    
                    MangaScreenTabs(manga: manga)
                }
                .padding(.leading, 12)
                .padding(.trailing, 16)
                .background(
                    VStack(spacing: 0) {
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color("BackgroundColor").opacity(0.0), location: 0.0),
                                .init(color: Color("BackgroundColor").opacity(1.0), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .center
                        )
                        .frame(height: 700)
                        
                        Color("BackgroundColor")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                        .frame(width: geometry.size.width)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    let someListManga = ListManga(
        id: "",
        title: "Some Manga",
        coverUrl: "Some URL",
        origin: ListManga.Origin.Local
    )
    
    let useCaseFactory = UseCaseFactory.shared
    
    let vm = MangaDetailsViewModel(
        listManga: someListManga,
        observer: useCaseFactory.makeObserveMangaDbChangesUseCase(),
        fetchHostSourceManga: useCaseFactory.makeFetchHostSourceMangaUseCase(),
        addMangaToLibrary: useCaseFactory.makeAddMangaToLibraryUseCase()
    )
    
    return MangaDetailsScreen(vm: vm)
}
