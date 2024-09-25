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
    let displayItems: [LibraryManga]
    
    @State private var currentSelection: Int
    @State private var isAutoScrollActive = true
    @State private var isChangingProgrammatically = false
    
    private let carouselHeight: CGFloat = 450
    private let imageScale: CGFloat = 250
    private let disableAutoScrollDuration: TimeInterval = 10
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init(manga: [LibraryManga]) {
        self.manga = manga
        if manga.count > 1 {
            // Duplicate the last and first items
            var items = manga
            items.insert(manga.last!, at: 0) // Insert last item at the beginning
            items.append(manga.first!) // Append first item at the end
            self.displayItems = items
            _currentSelection = State(initialValue: 1) // Start from the first real item
        } else {
            self.displayItems = manga
            _currentSelection = State(initialValue: 0)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentSelection) {
                ForEach(displayItems.indices, id: \.self) { index in
                    let item = displayItems[index]
                    ZStack {
                        // Background Image
                        KFImage(URL(string: item.coverUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: carouselHeight)
                            .clipped()
                            .blur(radius: 8)
                            .opacity(0.5)
                        
                        // Overlay to darken the background
                        AppColors.background
                            .opacity(0.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        VStack {
                            Spacer() // Push content to the bottom
                            
                            HStack(alignment: .bottom, spacing: 12) {
                                // Manga Cover Image
                                KFImage(URL(string: item.coverUrl))
                                    .resizable()
                                    .fade(duration: 0.25)
                                    .scaledToFill()
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .frame(width: imageScale * (11/16), height: imageScale)
                                
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
                    .tag(index) // Use the index as the tag
                }
            }
            .frame(height: carouselHeight)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: currentSelection) { newValue in
                if !isChangingProgrammatically {
                    disableAutoScrollTemporarily()
                }
                handleLooping(newValue)
            }
            .onReceive(timer) { _ in
                if isAutoScrollActive, !isChangingProgrammatically {
                    autoScroll()
                }
            }
            
            // Scroll Indicators
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(0..<manga.count, id: \.self) { index in
                        Rectangle()
                            .fill(currentPageIndex == index ? AppColors.text : AppColors.tint)
                            .frame(width: geo.size.width / CGFloat(manga.count), height: 2)
                            .animation(.easeInOut, value: currentSelection)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
    
    private var currentPageIndex: Int {
        if displayItems.count > 1 {
            if currentSelection == 0 {
                return manga.count - 1
            } else if currentSelection == displayItems.count - 1 {
                return 0
            } else {
                return currentSelection - 1
            }
        } else {
            return currentSelection
        }
    }
    
    private func handleLooping(_ newValue: Int) {
        // Handle infinite loop when user swipes manually
        if newValue == 0 {
            // Swiped to the fake first item
            DispatchQueue.main.async {
                withAnimation(.none) {
                    currentSelection = displayItems.count - 2
                }
            }
        } else if newValue == displayItems.count - 1 {
            // Swiped to the fake last item
            DispatchQueue.main.async {
                withAnimation(.none) {
                    currentSelection = 1
                }
            }
        }
    }
    
    private func autoScroll() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isChangingProgrammatically = true
            currentSelection += 1
            
            if currentSelection == displayItems.count - 1 {
                // Reset to the first real item without animation after the scrolling animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.none) {
                        currentSelection = 1
                        isChangingProgrammatically = false
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isChangingProgrammatically = false
                }
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
