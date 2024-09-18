//
//  VerticalReaderView.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/9/2024.
//
import SwiftUI
import Kingfisher
import VTabView

private struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// A view that displays the reader in vertical mode, supporting both paginated and continuous scrolling.
struct VerticalReaderView: View {
    @Binding var currentPage: Int
    let isPaginated: Bool
    let chapterContent: [URL]
    
    @State private var scrollPosition: Int?
    
    var body: some View {
        if isPaginated {
            // Paginated vertical reader using VTabView
            VTabView(selection: $currentPage) {
                ForEach(chapterContent.indices, id: \.self) { index in
                    RetryableImage(url: chapterContent[index], index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.all)
        } else {
            // Continuous vertical scrolling reader (Webtoon mode)
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    LazyVStack(spacing: 0) {
                        ForEach(chapterContent.indices, id: \.self) { index in
                            RetryableImage(url: chapterContent[index], index: index)
                                .id(index)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ViewOffsetKey.self, value: geo.frame(in: .named("scroll")).minY)
                                    }
                                )
                        }
                    }
                    .onPreferenceChange(ViewOffsetKey.self) { value in
                        print("Preference Changed: \(value)")
                        // Calculate the current page based on scroll position
                        let pageHeight = UIScreen.main.bounds.height
                        let page = max(0, Int(round(value / pageHeight)))
                        if currentPage != page {
                            currentPage = page
                        }
                    }
                    .onChange(of: currentPage) {
                        // Programmatically scroll to the new page
                        withAnimation(.bouncy) {
                            scrollViewProxy.scrollTo(currentPage, anchor: .top)
                        }
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .edgesIgnoringSafeArea(.all)
        }
    }
}
