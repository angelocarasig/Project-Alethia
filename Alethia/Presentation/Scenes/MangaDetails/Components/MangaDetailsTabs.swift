//
//  MangaDetailsTabs.swift
//  Alethia
//
//  Created by Angelo Carasig on 7/9/2024.
//

import SwiftUI

struct MangaScreenTabs: View {
    let manga: Manga
    @State private var selectedTab: MangaTabs = MangaTabs.chapters
    
    enum MangaTabs: String, CaseIterable {
        case chapters = "Chapters"
        case sources = "Sources"
        case tracking = "Tracking"
    }
    
    var body: some View {
        Picker("Active Tab", selection: $selectedTab) {
            ForEach(MangaTabs.allCases, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        
        Spacer().frame(height: 22)
        
        switch selectedTab {
        case .chapters:
            if let firstSource = manga.origins.first {
                ChapterButtons(chapters: firstSource.chapters)
            }
            else {
                Text("No Chapters Available")
            }
            
        case .sources:
            Text("Sources")
        case .tracking:
            Text("Tracking")
        }
    }
}
