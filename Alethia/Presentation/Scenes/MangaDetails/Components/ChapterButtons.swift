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
    
    @State private var sortOption: SortOptions = .chapterNumber
    @State private var sortDirection: SortDirections = .descending
    
    enum SortOptions: String, CaseIterable, Identifiable {
        case chapterNumber = "Chapter Number"
        case releaseDate = "Release Date"
        
        var id: String { self.rawValue }
    }
    
    enum SortDirections: String, CaseIterable, Identifiable {
        case descending = "Descending"
        case ascending = "Ascending"
        
        var id: String { self.rawValue }
    }
    
    private var threeDaysAgo: Date {
        Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
    }
    
    private func isNew(chapter: Chapter) -> Bool {
        return chapter.date >= threeDaysAgo
    }
    
    // Computed property to return sorted chapters based on sortOption and sortDirection
    private var sortedChapters: [Chapter] {
        let sorted: [Chapter]
        switch sortOption {
        case .chapterNumber:
            sorted = chapters.sorted { $0.chapterNumber < $1.chapterNumber }
        case .releaseDate:
            sorted = chapters.sorted { $0.date < $1.date }
        }
        
        return sortDirection == .ascending ? sorted : sorted.reversed()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Header()
            
            Divider().frame(height: 12)
            
            ChapterGrid()
        }
        .padding(.top, 10)
    }
}

private extension ChapterButtons {
    @ViewBuilder
    private func Header() -> some View {
        HStack {
            Text("\(chapters.count) Available Chapter\(chapters.count != 1 ? "s" : "")")
                .font(.title2)
                .foregroundColor(.primary)
            
            Spacer()
            
            MenuOptions()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func ChapterGrid() -> some View {
        LazyVGrid(columns: chapterColumns, alignment: .leading, spacing: 4) {
            ForEach(sortedChapters, id: \.self) { chapter in
                ChapterRow(chapter: chapter)
                Divider()
            }
        }
        .padding(12)
    }
    
    @ViewBuilder
    private func ChapterRow(chapter: Chapter) -> some View {
        NavigationLink(destination: ReaderScreen(vm: ViewModelFactory.shared.makeReaderViewModel(for: chapter))) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chapter \(chapter.chapterNumber.clean)\(chapter.chapterTitle.isEmpty ? "" : " - \(chapter.chapterTitle)")")
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                    
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
    
    @ViewBuilder
    private func MenuOptions() -> some View {
        Menu {
            VStack(alignment: .leading, spacing: 10) {
                Text("Sort By")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Button(action: {
                    sortOption = .chapterNumber
                }) {
                    HStack {
                        Text("Chapter Number")
                            .foregroundColor(.white)
                        Spacer()
                        if sortOption == .chapterNumber {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.5)))
                }
                
                Button(action: {
                    sortOption = .releaseDate
                }) {
                    HStack {
                        Text("Release Date")
                            .foregroundColor(.white)
                        Spacer()
                        if sortOption == .releaseDate {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.5)))
                }
            }
            
            Divider()
            
            // Sort Direction Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Sort Direction")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Button(action: {
                    sortDirection = .descending
                }) {
                    HStack {
                        Text("Descending")
                            .foregroundColor(.white)
                        Spacer()
                        if sortDirection == .descending {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.5)))
                }
                
                Button(action: {
                    sortDirection = .ascending
                }) {
                    HStack {
                        Text("Ascending")
                            .foregroundColor(.white)
                        Spacer()
                        if sortDirection == .ascending {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.5)))
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.black))
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }
}
