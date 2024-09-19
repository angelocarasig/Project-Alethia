//
//  ChapterButtons.swift
//  Alethia
//
//  Created by Angelo Carasig on 7/9/2024.
//

import SwiftUI
import LucideIcons

struct ChapterButtons: View {
    let chapters: [Chapter]
    let chapterColumns = [GridItem(.flexible())]
    
    @State private var isShowingSheet = false
    
    private var threeDaysAgo: Date {
        Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
    }
    
    private func isNew(chapter: Chapter) -> Bool {
        return chapter.date >= threeDaysAgo
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            Divider().frame(height: 12)
            
            chapterGrid
        }
    }
    
    @ViewBuilder
    private var header: some View {
        HStack {
            Text("\(chapters.count) Available Chapter\(chapters.count != 1 ? "s" : "")")
                .font(.title2)
            
            Spacer()
            
            Button {
                Haptics.impact()
                isShowingSheet = true
            } label: {
                Image(uiImage: Lucide.listFilter)
                    .lucide()
            }
            .padding(12)
            .foregroundColor(Color("TextColor"))
            .background(Color("TintColor"))
            .clipShape(Circle())
        }
    }
    
    @ViewBuilder
    private var chapterGrid: some View {
        LazyVGrid(columns: chapterColumns, alignment: .leading, spacing: 4) {
            ForEach(chapters, id: \.self) { chapter in
                chapterRow(chapter: chapter)
                Divider()
            }
        }
    }
    
    @ViewBuilder
    private func chapterRow(chapter: Chapter) -> some View {
        NavigationLink(destination: ReaderScreen(vm: ViewModelFactory.shared.makeReaderViewModel(for: chapter))) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chapter \(chapter.chapterNumber.clean)\(chapter.chapterTitle.isEmpty ? "" : " - \(chapter.chapterTitle)")")
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer().frame(height: 4)
                    
                    Text(chapter.date, style: .date)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text(chapter.author)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isNew(chapter: chapter) {
                    Text("NEW")
                        .font(.system(size: 16))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color("AlertColor"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
