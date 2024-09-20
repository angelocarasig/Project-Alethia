//
//  MangaDetailsScreen.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import SwiftUI

struct MangaDetailsScreen: View {
    @Bindable var vm: MangaDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            if let manga = vm.manga {
                ContentView(manga)
                    .blur(radius: vm.isFullScreen ? 6 : 0)
                    .transition(.opacity)
                
                ChapterPlayer(
                    chapters: manga.origins.first?.chapters ?? [],
                    imageURL: URL(string: manga.coverUrl)!,
                    isFullScreen: $vm.isFullScreen
                )
                .transition(.opacity)
            } else {
                SkeletonView()
                    .transition(.opacity)
            }
        }
        // Attach the animation to the ZStack, triggered by changes in vm.manga
        .animation(.easeInOut(duration: 0.5), value: vm.manga != nil)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                try await vm.onOpen()
            }
        }
        .onDisappear {
            vm.onClose()
        }
        .alert(isPresented: $vm.showAlert) {
            Alert(
                title: Text("Remove Manga from Library?"),
                message: Text("You will be redirected to the previous screen after removal. Are you sure you want to remove this manga?"),
                primaryButton: .destructive(Text("Remove"), action: {
                    Task {
                        await removeFrom()
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}

private extension MangaDetailsScreen {
    func addToLibrary() async {
        await vm.addToLibrary()
    }
    
    func removeFrom() async {
        await vm.removeFromLibrary()
        
        if ActiveHostManager.shared.getActiveHost() == nil || ActiveHostManager.shared.getActiveSource() == nil {
            print("Active Host or Active Source is null. Dismissing...")
            DispatchQueue.main.async {
                dismiss()
            }
        }
    }
    
    private func checkAndRemoveFromLibrary() {
        if ActiveHostManager.shared.getActiveHost() == nil || ActiveHostManager.shared.getActiveSource() == nil {
            vm.showAlert = true
        } else {
            Task {
                await removeFrom()
            }
        }
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
                        addToLibrary: { await addToLibrary() },
                        removeFromLibrary: { checkAndRemoveFromLibrary() }
                    )
                    
                    Gap(12)
                    
                    MangaDetailsDescription(description: manga.synopsis)
                    
                    Gap(22)
                    
                    Tags(tags: manga.tags)
                    
                    Gap(12)
                    
                    Divider().frame(height: 6)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alternative Titles")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(manga.alternativeTitles, id: \.self) { title in
                            Text(title)
                                .font(.system(size: 16))
                                .foregroundColor(Color("TextColor").opacity(0.75))
                            
                            Gap(2)
                        }
                    }
                    
                    Gap(22)
                    
                    Additional(manga)
                    
                    Gap(12)
                    
                    Divider().frame(height: 6)
                    
                    // Gap for chapter player height
                    Gap(60)
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
            .refreshable {
                print("Triggered Refresh!")
            }
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
        fetchHostSourceMangaUseCase: useCaseFactory.makeFetchHostSourceMangaUseCase(),
        observeMangaUseCase: useCaseFactory.makeObserveMangaUseCase(),
        addMangaToLibraryUseCase: useCaseFactory.makeAddMangaToLibraryUseCase(),
        removeMangaFromLibraryUseCase: useCaseFactory.makeRemoveMangaFromLibraryUseCase()
    )
    
    return MangaDetailsScreen(vm: vm)
}

