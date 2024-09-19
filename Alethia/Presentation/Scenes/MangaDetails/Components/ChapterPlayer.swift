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
    var latestChapter: Chapter? {
        chapters.last
    }
    
    let imageURL: URL?
    @Binding var isFullScreen: Bool
    @State private var backgroundColor: Color = Color("BackgroundColor")
    
    var body: some View {
        VStack {
            if !isFullScreen {
                Spacer()
            }
            
            if let chapter = latestChapter {
                VStack {
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
                                    .foregroundColor(Color("TextColor"))
                                    .lineLimit(1)
                                    .transition(.move(edge: .bottom))
                            }
                            else {
                                Text("Chapter \(Int(chapter.chapterNumber)) \(chapter.chapterTitle.isEmpty ? "" : " - \(chapter.chapterTitle)")")
                                    .font(.headline)
                                    .foregroundColor(Color("TextColor"))
                                    .lineLimit(1)
                                
                                Text(chapter.author)
                                    .font(.subheadline)
                                    .foregroundColor(Color("TextColor").opacity(0.7))
                                    .lineLimit(1)
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
                                .lucide(color: Color("TextColor"))
                                .frame(width: 30, height: 30)
                        }
                        .padding(.trailing, 10)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isFullScreen ? Color("BackgroundColor") : backgroundColor.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: -2)
                    )
                    .frame(height: 60)
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom))
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color("TextColor")),
                        alignment: .bottom
                    )
                    
                    if isFullScreen {
                        FullScreenView()
                    }
                }
                .frame(maxHeight: isFullScreen ? .infinity : nil)
                .background(isFullScreen ? Color("BackgroundColor").opacity(0.9) : backgroundColor)
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
                .stroke(Color("TintColor").opacity(0.3), lineWidth: 2.5)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(Color("TextColor"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: progress)
        }
    }
    
    @ViewBuilder
    
    func FullScreenView() -> some View {
        ScrollView {
            ChapterButtons(chapters: chapters)
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
                
                let color = cgColors.first!
                
                ColorCacheManager.shared.setColor(color, for: url)
                backgroundColor = Color(uiColor: color)
                
            case .failure(let error):
                print("Failed to load image: \(error)")
            }
        }
    }
}
