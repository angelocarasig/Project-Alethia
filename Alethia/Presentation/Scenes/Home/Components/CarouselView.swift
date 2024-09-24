//
//  CarouselView.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/9/2024.
//

import SwiftUI
import Kingfisher
import LucideIcons

struct CarouselView: View {
    let manga: [LibraryManga]
    
    @State private var currentSelection: String?
    @State private var isAutoScrollActive = true
    @State private var isChangingProgrammatically = false
    
    private let carouselHeight: CGFloat = 450
    private let imageScale: CGFloat = 250
    private let disableAutoScrollDuration: TimeInterval = 10
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentSelection) {
                ForEach(manga) { item in
                    ZStack {
                        // Background
                        KFImage(URL(string: item.coverUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: carouselHeight)
                            .clipped()
                            .blur(radius: 8)
                            .opacity(0.5)
                        
                        // Make BG darker
                        AppColors.background
                            .opacity(0.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        VStack {
                            // To push content to bottom
                            Spacer()
                            
                            HStack(alignment: .bottom, spacing: 12) {
                                // Manga Cover Image
                                KFImage(URL(string: item.coverUrl))
                                    .resizable()
                                    .fade(duration: 0.25)
                                    .scaledToFill()
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .frame(width: imageScale * (11/16), height: imageScale)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(item.title)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .lineLimit(2)
                                        .foregroundColor(AppColors.text)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text(item.synopsis)
                                        .font(.subheadline)
                                        .lineLimit(8)
                                        .foregroundColor(AppColors.text.opacity(0.75))
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        NavigationLink(
                                            destination: MangaDetailsScreen(
                                                vm: ViewModelFactory.shared.makeMangaDetailsViewModel(for: item.toListManga())
                                            )
                                        ) {
                                            Text("View Details")
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .lineLimit(1)
                                                .padding(.vertical, 14)
                                                .frame(maxWidth: .infinity)
                                                .foregroundStyle(AppColors.background)
                                                .background(
                                                    AppColors.text.opacity(0.85),
                                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                )
                                        }
                                        
                                        Button {
                                            Haptics.impact()
                                            print("Continue Reading!")
                                        } label: {
                                            Image(uiImage: Lucide.bookOpen)
                                                .lucide(color: AppColors.background)
                                        }
                                        .padding(12)
                                        .background(AppColors.text.opacity(0.85))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                            .frame(maxHeight: imageScale)
                            .padding(16)
                            .padding(.bottom, 20)
                        }
                    }
                    .tag(item.id) // Use the item's id as the tag
                }
            }
            .frame(height: carouselHeight)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: currentSelection) { _ in
                if !isChangingProgrammatically {
                    disableAutoScrollTemporarily()
                }
            }
            .onReceive(timer) { _ in
                if isAutoScrollActive, !isChangingProgrammatically {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isChangingProgrammatically = true
                        if let currentSelection = currentSelection,
                           let currentIndex = manga.firstIndex(where: { $0.id == currentSelection }) {
                            let nextIndex = (currentIndex + 1) % manga.count
                            self.currentSelection = manga[nextIndex].id
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            isChangingProgrammatically = false
                        }
                    }
                }
            }
            
            // Scroll Indicators
            GeometryReader { geo in
                HStack {
                    ForEach(manga) { item in
                        Rectangle()
                            .fill(currentSelection == item.id ? AppColors.text : AppColors.tint)
                            .frame(width: (geo.size.width / 1.25) / CGFloat(manga.count), height: 2)
                            .animation(.easeInOut, value: currentSelection)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
    
    private func disableAutoScrollTemporarily() {
        isAutoScrollActive = false
        DispatchQueue.main.asyncAfter(deadline: .now() + disableAutoScrollDuration) {
            isAutoScrollActive = true
        }
    }
}
