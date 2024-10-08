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
    @Bindable var vm: SourceContentViewModel
    
    var body: some View {
        VStack {
            if vm.isLoadingRootContent {
                ProgressView()
            } else {
                ContentView()
            }
        }
        .navigationTitle(vm.activeSource.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    print("Settings tapped")
                }) {
                    Text(Image(systemName: "gearshape"))
                }
            }
        }
        .onAppear {
            vm.onRootPageLoad()
        }
    }
}

private extension SourceContent {
    func ContentView() -> some View {
        ScrollView {
            Gap(1)
            
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
                            MangaCard(item: listManga, isInLibrary: manga.inLibrary)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .refreshable {
            Haptics.impact()
            vm.resetRootContent()
            vm.onRootPageLoad()
        }
    }
}
