//
//  MangaDetailsScreen.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import SwiftUI
import LucideIcons

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
                    origins: manga.origins,
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
        .animation(.easeInOut(duration: 0.25), value: vm.manga != nil)
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
    private func addToLibrary() async {
        await vm.addToLibrary()
    }
    
    private func removeFrom() async {
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
    
    private func addOrigin() async {
        await vm.addOrigin()
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
                        removeFromLibrary: { checkAndRemoveFromLibrary() },
                        addOrigin: { await addOrigin() }
                    )
                    
                    Gap(12)
                    
                    MangaDetailsDescription(description: manga.synopsis)
                    
                    Gap(22)
                    
                    Tags(tags: manga.tags)
                    
                    Gap(12)
                    
                    Divider().frame(height: 6)
                    
                    ExpandableList(name: "Sources", isExpanded: $vm.expandedSources) {
                        VStack(spacing: 8) {
                            ForEach(vm.originData, id: \.origin.id) { origin in
                                // If there's an active host
                                if ActiveHostManager.shared.hasActiveHost() && origin.origin.slug == vm.newOriginData?.origin.slug {
                                    OriginCell(data: origin, sourcePresent: vm.sourcePresent)
                                }
                                else {
                                    OriginCell(data: origin, sourcePresent: true)
                                }
                            }
                        }
                        Gap(4)
                    }
                    
                    Gap(8)
                    
                    // TODO: Figure out why the origincelldata ExpandableList can't be hidden when this open
                    // Tracking, will refactor later
                    ExpandableList(name: "Tracking", isExpanded: $vm.expandedTracking) {
                        VStack(spacing: 8) {
                            ZStack {
                                Image("AniList")
                                    .resizable()
                                    .scaledToFill()
                                    .blur(radius: 16)
                                    .overlay(AppColors.background.opacity(0.3))
                                    .cornerRadius(15)
                                    .clipped()
                                    .frame(height: 100)
                                
                                HStack {
                                    Image("AniList")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(4)
                                        .clipped()
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(vm.manga!.title)
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(AppColors.text)
                                            .lineLimit(1)
                                        
                                        Text("\(vm.manga?.author ?? "No Author"), \(vm.manga?.artist ?? "No Artist")")
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.text.opacity(0.75))
                                            .lineLimit(1)
                                        
                                        HStack {
                                            Text("1/\(vm.manga!.origins.first!.chapters.count) Chapters")
                                                .font(.subheadline)
                                                .foregroundColor(AppColors.text)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                            
                                            Text("Reading")
                                                .font(.system(size: 14))
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 8)
                                                .foregroundColor(AppColors.text)
                                                .background(Color.orange)
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding(.leading, 10)
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Image(uiImage: Lucide.ellipsisVertical)
                                            .lucide(color: AppColors.text)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AppColors.text)
                                    }
                                    .padding(.trailing, 10)
                                }
                                .padding()
                            }
                            .background(Color.clear)
                            .cornerRadius(15)
                            .shadow(radius: 2)
                            .grayscale(vm.inLibrary ? 0 : 1)
                        }
                    }
                    
                    Gap(8)
                    
                    Additional(manga)
                    
                    Gap(18)
                    
                    Divider().background(AppColors.text)
                    
                    Gap(12)
                    
                    AlternativeTitles(titles: manga.alternativeTitles)
                    
                    // Gap for chapter player height
                    Gap(60)
                }
                .padding(.leading, 12)
                .padding(.trailing, 16)
                .background(
                    VStack(spacing: 0) {
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: AppColors.background.opacity(0.0), location: 0.0),
                                .init(color: AppColors.background.opacity(1.0), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .center
                        )
                        .frame(height: 700)
                        
                        AppColors.background
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
