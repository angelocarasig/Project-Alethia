//
//  LibraryScreen.swift
//  Alethia
//
//  Created by Angelo Carasig on 20/9/2024.
//

import SwiftUI
import LucideIcons

enum SortOption: String, CaseIterable {
    case title = "Title"
    case addedAt = "Date Added"
    case updatedAt = "Date Updated"
    case lastReadAt = "Last Read At"
}

enum SortDirection {
    case ascending
    case descending
}

struct LibraryScreen: View {
    @Bindable var vm: LibraryViewModel
    
    @State private var searchQuery = ""
    @State private var tabSelection = 0
    
    // Modals
    @State private var showingSortModal: Bool = false
    @State private var showingFilterModal: Bool = false
    
    // Sort Options
    @State var selectedSortOption: SortOption = .lastReadAt
    @State var selectedSortDirection: SortDirection = .descending
    
    // Filter Options
    @State var selectedContentStatus: Set<ContentStatus> = []
    @State var selectedContentRating: Set<ContentRating> = []
    @State var lastReadAt = Date()
    @State var addedAt = Date()
    @State var updatedAt = Date()
    
    var body: some View {
        NavigationStack {
            ContentView()
                .onAppear {
                    Task {
                        await vm.onOpen()
                    }
                }
                .navigationTitle("Library")
                .searchable(text: $searchQuery)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Haptics.impact()
                            showingSortModal = true
                        } label: {
                            Image(uiImage: Lucide.listFilter)
                                .lucide(color: AppColors.text)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Haptics.impact()
                            showingFilterModal = true
                        } label: {
                            Image(uiImage: Lucide.filter)
                                .lucide(color: AppColors.text)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Haptics.impact()
                            print("Settings!")
                        } label: {
                            Text(Image(systemName: "gearshape"))
                                .foregroundStyle(AppColors.text)
                        }
                    }
                }
                .sheet(isPresented: $showingSortModal) {
                    SortModal()
                }
                .sheet(isPresented: $showingFilterModal) {
                    FilterModal()
                }
        }
    }
    
    @ViewBuilder
    func ContentView() -> some View {
        TabSelectionView(tabSelection: $tabSelection)
        
        TabView(selection: $tabSelection) {
            DetailsView(content: vm.manga.filter { $0.contentStatus == .ongoing })
                .font(.largeTitle)
                .fontWeight(.black)
                .tag(0)
            
            DetailsView(content: vm.manga.filter { $0.contentStatus == .completed })
                .font(.largeTitle)
                .fontWeight(.black)
                .tag(1)
            
            DetailsView(content: vm.manga.filter { $0.contentStatus == .cancelled })
                .font(.largeTitle)
                .fontWeight(.black)
                .tag(2)
            
            DetailsView(content: vm.manga.filter { $0.contentStatus == .hiatus })
                .font(.largeTitle)
                .fontWeight(.black)
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

private struct TabSelectionView: View {
    @Binding var tabSelection: Int
    @Namespace private var buttonId
    private let selectionButtons = ["Ongoing", "Completed", "Cancelled", "Hiatus"]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                ForEach(selectionButtons.indices, id: \.self) { index in
                    VStack {
                        Button(selectionButtons[index]) {
                            withAnimation {
                                tabSelection = index
                            }
                        }
                        .foregroundStyle(tabSelection == index ? AppColors.text : .secondary)
                        .padding(.horizontal)
                        
                        if tabSelection == index {
                            Capsule()
                                .frame(width: 80, height: 4)
                                .padding(.horizontal, 4)
                                .foregroundStyle(.blue)
                                .matchedGeometryEffect(id: "ID", in: buttonId)
                        }
                        else {
                            EmptyView()
                                .frame(height: 4)
                                .matchedGeometryEffect(id: "ID", in: buttonId)
                        }
                    }
                }
                Spacer()
            }
        }
        .scrollIndicators(.never)
    }
}

private extension LibraryScreen {
    @ViewBuilder
    func DetailsView(content: [Manga]) -> some View {
        let dimensions = DimensionsCache.shared.dimensions
        ScrollView {
            if vm.contentLoaded {
                Spacer().frame(height: 20)
                
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: dimensions.width), spacing: 0)],
                    spacing: 0
                ) {
                    ForEach(content, id: \.id) { manga in
                        MangaCard(item: ListManga(id: manga.id, title: manga.title, coverUrl: manga.coverUrl, origin: ListManga.Origin.Local ))
                    }
                }
                .padding(.horizontal, 10)
            }
            else {
                VStack {
                    Text("Loading Content...")
                    ProgressView()
                }
            }
        }
    }
}
