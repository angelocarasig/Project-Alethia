//
//  ReaderScreen.swift
//  Alethia
//
//  Created by Angelo Carasig on 15/9/2024.
//

import SwiftUI

/// The main view for displaying the reader screen in various reading modes.
struct ReaderScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var vm: ReaderViewModel
    
    var body: some View {
        ReaderOverlay(vm: vm) {
            readerView
        }
    }
    
    @ViewBuilder
    var readerView: some View {
        if vm.config.readerDirection == ReaderDirection.LTR || vm.config.readerDirection == ReaderDirection.RTL {
            HorizontalReaderView(
                currentPage: $vm.currentPage,
                toggleOverlay: $vm.displayOverlay,
                chapter: vm.chapter,
                referer: vm.referer,
                nextChapter: vm.nextChapter,
                previousChapter: vm.previousChapter,
                isRTL: vm.config.readerDirection == .RTL,
                chapterContent: vm.chapterContent,
                onLoadNextChapter: { Task { await vm.goToNextChapter() }},
                onLoadPreviousChapter: {Task { await vm.goToPreviousChapter() }}
            )
        } else {
            VerticalReaderView(
                currentPage: $vm.currentPage,
                chapter: vm.chapter,
                isPaginated: vm.config.readerDirection == .Vertical,
                chapterContent: vm.chapterContent,
                referer: vm.referer
            )
        }
    }
}
