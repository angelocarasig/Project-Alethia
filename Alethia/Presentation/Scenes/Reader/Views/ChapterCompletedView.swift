//
//  ChapterCompletedView.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/9/2024.
//

import SwiftUI

struct ChapterCompletedView: View {
    let chapter: Chapter
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Completed: Chapter \(chapter.chapterNumber.clean)")
            
            Spacer()
            
            Text("Up Next: Chapter \(chapter.chapterNumber.clean)")
            
            Spacer()
        }
    }
}

