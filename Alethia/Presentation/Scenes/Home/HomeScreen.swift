//
//  HomeScreen.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/9/2024.
//

import SwiftUI
import LucideIcons

struct HomeScreen: View {
    @Bindable var vm: HomeViewModel
    
    @State var activeTab: MangaTabs = .recentlyRead
    
    enum MangaTabs: String, CaseIterable {
        case featured = "Featured"
        case recentlyRead = "Recently Read"
        case recentlyAdded = "Recently Added"
    }
    
    var body: some View {
        NavigationStack {
            ContentView()
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            print("Settings tapped")
                        }) {
                            Text(Image(systemName: "gearshape"))
                                .foregroundStyle(AppColors.text)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Haptics.impact()
                            print("Notifications!")
                        } label: {
                            Image(uiImage: Lucide.bell)
                                .lucide(color: AppColors.text)
                        }
                    }
                }
                .onAppear {
                    Task {
                        await vm.onOpen()
                    }
                }
        }
    }
}

extension HomeScreen {
    @ViewBuilder
    func ContentView() -> some View {
        if !vm.contentLoaded {
            ProgressView()
        }
        else if vm.manga.isEmpty {
            Text("No Manga In Library")
        }
        else {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    carouselSection()
                    
                    recentlyReadSection()
                    
                    recentlyAddedSection()
                    
                    ForEach(vm.categoriedManga) { manga in
                        categoriedSection(manga)
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .top)
        }
    }
    
    @ViewBuilder
    private func carouselSection() -> some View {
        if !vm.manga.isEmpty {
            // Just grab random ones
            CarouselView(manga: Array(vm.manga.shuffled().prefix(10)) )
        }
    }
    
    @ViewBuilder
    private func recentlyReadSection() -> some View {
        Text("Recently Read")
            .font(.title)
            .fontWeight(.semibold)
            .padding(.leading, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(vm.recentlyReadManga, id: \.id) { manga in
                    MangaCard(item: manga.toLocalListManga())
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private func recentlyAddedSection() -> some View {
        Text("Recently Added")
            .font(.title)
            .fontWeight(.semibold)
            .padding(.leading, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(vm.recentlyAddedManga, id: \.id) { manga in
                    MangaCard(item: manga.toLocalListManga())
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private func categoriedSection(_ manga: CategoriedManga) -> some View {
        Text(manga.category)
            .font(.title)
            .fontWeight(.semibold)
            .padding(.leading, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(manga.manga, id: \.self.id) { manga in
                    MangaCard(item: manga.toLocalListManga())
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    HomeScreen(vm: ViewModelFactory.shared.makeHomeViewModel())
}
