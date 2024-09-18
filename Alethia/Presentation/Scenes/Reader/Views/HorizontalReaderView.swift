//
//  HorizontalReaderView.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/9/2024.
//

import SwiftUI
import Kingfisher

/// A view that displays the reader in horizontal mode, supporting both LTR and RTL directions.
struct HorizontalReaderView: View {
    @Binding var currentPage: Int
    let isRTL: Bool
    let chapterContent: [URL]

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(chapterContent.indices, id: \.self) { index in
                RetryableImage(url: chapterContent[index], index: index)
                    .tag(index)
            }
        }
        // Set the layout direction based on the reading direction.
        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
        // Use a page tab view style without the page indicator.
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .edgesIgnoringSafeArea(.all)
    }
}
