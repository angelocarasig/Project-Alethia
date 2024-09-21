//
//  HorizontalReaderView.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/9/2024.
//

import SwiftUI
import Kingfisher

struct HorizontalReaderView: View {
    @Binding var currentPage: Int
    @Binding var toggleOverlay: Bool
    let chapter: Chapter
    let referer: String
    let nextChapter: Chapter?
    let previousChapter: Chapter?
    let isRTL: Bool
    let chapterContent: [URL]
    
    let onLoadNextChapter: () -> Void
    
    let onLoadPreviousChapter: () -> Void
    
    var body: some View {
        TabView(selection: $currentPage) {
            if previousChapter != nil {
                Text("")
                    .tag(-2)
            }
            
            PreviousChapterView(chapter: chapter, previousChapter: previousChapter)
                .tag(-1)
                .onAppear {
                    toggleOverlay = false
                }
            
            ForEach(chapterContent.indices, id: \.self) { index in
                RetryableImage(url: chapterContent[index], index: index, referer: referer)
                    .tag(index)
            }
            
            NextChapterView(chapter: chapter, nextChapter: nextChapter)
                .tag(chapterContent.count)
                .onAppear {
                    toggleOverlay = false
                }
            
            // Swiping to this will trigger the onChange
            if nextChapter != nil {
                Text("")
                    .tag(chapterContent.count + 1)
            }
        }
        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .edgesIgnoringSafeArea(.all)
        .onChange(of: currentPage) { newValue, oldValue in
            // If currently on index -2 go to previous
            if newValue == -2, let previous = previousChapter {
                print("Loading Previous Chapter \(previous.chapterNumber)...")
                onLoadPreviousChapter()
            }
            
            // Same with index of count + 1
            else if newValue == chapterContent.count + 1, let next = nextChapter {
                print("Loading Next Chapter \(next.chapterNumber)...")
                onLoadNextChapter()
            }
        }

    }
}

private struct PreviousChapterView: View {
    let chapter: Chapter
    let previousChapter: Chapter?
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Currently: Chapter \(chapter.chapterNumber.clean)")
                .font(.title)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let previous = previousChapter {
                Text("Previous: Chapter \(previous.chapterNumber.clean)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Published by: \(previous.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
            } else {
                Text("There is no previous chapter.")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

private struct NextChapterView: View {
    let chapter: Chapter
    let nextChapter: Chapter?
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Completed: Chapter \(chapter.chapterNumber.clean)")
                .font(.title)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let next = nextChapter {
                Text("Up Next: Chapter \(next.chapterNumber.clean)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Published by: \(next.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
            } else {
                Text("There is no next chapter.")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}
