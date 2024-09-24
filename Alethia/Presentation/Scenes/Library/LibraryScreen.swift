//
//  LibraryScreen.swift
//  Alethia
//
//  Created by Angelo Carasig on 20/9/2024.
//

import SwiftUI
import LucideIcons

struct LibraryScreen: View {
    @Bindable var vm: LibraryViewModel
    
    @State var showRefresh: Bool = false
    
    var body: some View {
        NavigationStack {
            ContentView()
                .searchable(text: $vm.searchQuery)
                .onAppear {
                    Task {
                        await vm.onOpen()
                    }
                }
                .navigationTitle("Library")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Haptics.impact()
                            vm.toggleSortModal()
                        } label: {
                            Image(uiImage: Lucide.listFilter)
                                .lucide(color: AppColors.text)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Haptics.impact()
                            vm.toggleFilterModal()
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
                .sheet(isPresented: $vm.showingSortModal) {
                    SortModal()
                }
                .sheet(isPresented: $vm.showingFilterModal) {
                    FilterModal()
                }
        }
    }
    
    @ViewBuilder
    func ContentView() -> some View {
        // Add gap since it seems to be fat-fingering the search without it
        Gap(8)
        TabSelectionView(tabSelection: $vm.tabSelection)
        
        TabView(selection: $vm.tabSelection) {
            DetailsView(content: vm.filteredManga(for: .ongoing))
                .font(.largeTitle)
                .fontWeight(.black)
                .tag(0)
            
            DetailsView(content: vm.filteredManga(for: .completed))
                .font(.largeTitle)
                .fontWeight(.black)
                .tag(1)
            
            DetailsView(content: vm.filteredManga(for: .cancelled))
                .font(.largeTitle)
                .fontWeight(.black)
                .tag(2)
            
            DetailsView(content: vm.filteredManga(for: .hiatus))
                .font(.largeTitle)
                .fontWeight(.black)
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

private extension LibraryScreen {
    @ViewBuilder
    func DetailsView(content: [LibraryManga]) -> some View {
        let dimensions = DimensionsCache.shared.dimensions
        
        if vm.contentLoaded {
            if content.isEmpty {
                Text("No Manga For This Section.")
                    .font(.callout)
                    .fontWeight(.medium)
                    .padding()
            } else {
                ScrollView {
                    Spacer().frame(height: 20)
                    
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: dimensions.width), spacing: 0)],
                        spacing: 0
                    ) {
                        ForEach(content, id: \.id) { manga in
                            MangaCard(item: manga.toListManga())
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.horizontal, 10)
                    .animation(.easeInOut(duration: 0.3), value: content)
                }
                .refreshable {
                    showRefresh = true
                    // Handle refresh action
                }
                .alert("Update Content?", isPresented: $showRefresh, actions: {
                    Button("Confirm", role: .none) {
                        print("Updating!!!")
                    }
                    Button("Cancel", role: .cancel) {
                        showRefresh = false
                    }
                }, message: {
                    Text("This will fetch all sources for updates for the manga in the current tab.")
                })
            }
        } else {
            VStack {
                Text("Loading Content...")
                    .font(.callout)
                    .fontWeight(.medium)
                    .padding()
                
                ProgressView()
            }
            .padding()
        }
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
                        } else {
                            EmptyView()
                                .frame(height: 4)
                                .matchedGeometryEffect(id: "ID", in: buttonId)
                        }
                    }
                }
                Spacer()
            }
        }
        .onChange(of: tabSelection) {
            withAnimation { }
        }
        .scrollIndicators(.never)
    }
}
