//
//  ChapterPlayer.swift
//  Alethia
//
//  Created by Angelo Carasig on 19/9/2024.
//

import SwiftUI
import LucideIcons
import Kingfisher
import DominantColors

struct ChapterPlayer: View {
    let chapters: [Chapter]
    let origins: [Origin]
    
    var latestChapter: Chapter? {
        chapters.first
    }
    
    let imageURL: URL?
    @Binding var isFullScreen: Bool
    @State private var backgroundColor: Color = AppColors.background
    
    var body: some View {
        VStack {
            if !isFullScreen {
                Spacer()
            }
            
            if let chapter = latestChapter {
                VStack(spacing: 0) {
                    HStack(alignment: .center, spacing: 16) {
                        if !isFullScreen {
                            RadialProgress(progress: 0.75)
                                .frame(width: 35, height: 35)
                                .padding(.leading, 10)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if isFullScreen {
                                Text("Chapter List")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.text)
                                    .lineLimit(1)
                                    .transition(.move(edge: .bottom))
                            }
                            else {
                                NavigationLink(destination: ReaderScreen(vm: ViewModelFactory.shared.makeReaderViewModel(chapter: chapter, origins: origins))) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Chapter \(Int(chapter.chapterNumber)) \(chapter.chapterTitle.isEmpty ? "" : " - \(chapter.chapterTitle)")")
                                            .font(.headline)
                                            .foregroundColor(AppColors.text)
                                            .lineLimit(1)
                                        
                                        Text(chapter.author)
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.text.opacity(0.7))
                                            .lineLimit(1)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                isFullScreen.toggle()
                            }
                        }) {
                            Image(uiImage: isFullScreen ? Lucide.chevronDown : Lucide.chevronUp)
                                .lucide(color: AppColors.text)
                                .frame(width: 30, height: 30)
                        }
                        .padding(.trailing, 10)
                    }
                    // Player Height
                    .frame(height: 60)
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom))
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(AppColors.text),
                        alignment: .bottom
                    )
                    
                    if isFullScreen {
                        FullScreenView()
                    }
                }
                .frame(maxHeight: isFullScreen ? .infinity : nil)
                .background(isFullScreen ? AppColors.background.opacity(0.9) : backgroundColor)
                .cornerRadius(isFullScreen ? 0 : 12)
                .onAppear {
                    extractDominantColor()
                }
            }
        }
    }
}

private extension ChapterPlayer {
    @ViewBuilder
    func RadialProgress(progress: Double) -> some View {
        ZStack {
            Circle()
                .stroke(AppColors.tint.opacity(0.3), lineWidth: 2.5)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(AppColors.text, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: progress)
        }
    }
    
    @ViewBuilder
    
    func FullScreenView() -> some View {
        ScrollView {
            ChapterButtons(chapters: chapters, origins: origins)
        }
    }
}

// MARK - Functions

private extension ChapterPlayer {
    private func extractDominantColor() {
        guard let url = imageURL else { return }
        
        if let cachedUIColor = ColorCacheManager.shared.getColor(for: url) {
            let swiftUIColor = Color(cachedUIColor)
            self.backgroundColor = swiftUIColor
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                guard let cgColors = try? DominantColors.dominantColors(
                    uiImage: value.image,
                    maxCount: 6,
                    options: [.excludeBlack, .excludeGray, .excludeWhite],
                    sorting: .darkness
                ), !cgColors.isEmpty else { return }
                
                let color = cgColors.count > 1 ? cgColors[1] : cgColors[0]
                
                ColorCacheManager.shared.setColor(color, for: url)
                backgroundColor = Color(uiColor: color)
                
            case .failure(let error):
                print("Failed to load image: \(error)")
            }
        }
    }
}
