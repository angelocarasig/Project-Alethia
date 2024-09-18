//
//  MangaDetailsChapters.swift
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
    @State private var selectedSortOption: SortOption = .numberAscending
    @State private var selectedAuthor: String = "All"
    
    private var sortedAndFilteredChapters: [Chapter] {
        var filteredChapters = Array(chapters)
        
        if selectedAuthor != "All" {
            filteredChapters = filteredChapters.filter { $0.author == selectedAuthor }
        }
        
        switch selectedSortOption {
        case .numberAscending:
            filteredChapters.sort { $0.chapterNumber < $1.chapterNumber }
        case .numberDescending:
            filteredChapters.sort { $0.chapterNumber > $1.chapterNumber }
        case .dateAscending:
            filteredChapters.sort { $0.date < $1.date }
        case .dateDescending:
            filteredChapters.sort { $0.date > $1.date }
        }
        
        return filteredChapters
    }
    
    enum SortOption: String, CaseIterable {
        case numberAscending = "Number (A-Z)"
        case numberDescending = "Number (Z-A)"
        case dateAscending = "Date (A-Z)"
        case dateDescending = "Date (Z-A)"
    }
    
    private var uniqueAuthors: [String] {
        let authors = chapters.map { $0.author }
        return Array(Set(authors)).sorted() + ["All"]
    }
    
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
            Text("\(sortedAndFilteredChapters.count) \(selectedAuthor != "All" ? "Filtered" : "Available") Chapter\(sortedAndFilteredChapters.count != 1 ? "s" : "")")
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
            .sheet(isPresented: $isShowingSheet) {
                sheetContent
            }
        }
    }
    
    @ViewBuilder
    private var sheetContent: some View {
        NavigationView {
            Form {
                Section(header: Text("Sort By")) {
                    Picker("Sort Option", selection: $selectedSortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Filter By Author")) {
                    Picker("Author", selection: $selectedAuthor) {
                        ForEach(uniqueAuthors, id: \.self) { author in
                            Text(author).tag(author)
                        }
                    }
                }
            }
            .navigationTitle("Sort & Filter")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        isShowingSheet = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var chapterGrid: some View {
        LazyVGrid(columns: chapterColumns, alignment: .leading, spacing: 4) {
            ForEach(sortedAndFilteredChapters, id: \.self) { chapter in
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



#Preview {
    var sampleChapters: [Chapter] = []
    
    let chapter1 = Chapter(
        originId: "Some ID",
        slug: "chapter-abc",
        mangaSlug: "manga-abc",
        chapterNumber: 1,
        chapterTitle: "The Beginning",
        author: "The Author",
        date: Date()
    )
    
    let chapter2 = Chapter(
        originId: "Some ID",
        slug: "chapter-abc",
        mangaSlug: "manga-abc",
        chapterNumber: 2,
        chapterTitle: "The Beginning pt. 2",
        author: "The Author",
        date: Date()
    )
    
    let chapter3 = Chapter(
        originId: "Some ID",
        slug: "chapter-abc",
        mangaSlug: "manga-abc",
        chapterNumber: 2.5,
        chapterTitle: "The Beginning pt. 2.5",
        author: "The Author",
        date: Date()
    )
    
    let chapter4 = Chapter(
        originId: "Some ID",
        slug: "chapter-abc",
        mangaSlug: "manga-abc",
        chapterNumber: 3,
        chapterTitle: "The Beginning with lots of extra characters sdlfgslfjgnsdljfhgb",
        author: "The Author",
        date: Date()
    )
    
    sampleChapters.append(chapter1)
    sampleChapters.append(chapter2)
    sampleChapters.append(chapter3)
    sampleChapters.append(chapter4)
    
    return ChapterButtons(chapters: sampleChapters)
}
