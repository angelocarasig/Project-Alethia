//
//  ReaderViewModel.swift
//  Alethia
//
//  Created by Angelo Carasig on 15/9/2024.
//

import Foundation
import RealmSwift
import Kingfisher

enum ReaderDirection {
    case RTL
    case LTR
    case Vertical
    case Webtoon
}

struct ReaderConfig {
    var readerDirection: ReaderDirection
}

let defaultConfig: ReaderConfig = ReaderConfig(
    readerDirection: ReaderDirection.LTR
)

@Observable
final class ReaderViewModel {
    private let chapter: Chapter
    var chapterContent: [URL] = []
    
    private var fetchHostSourceMangaChapterContentUseCase: FetchHostSourceMangaChapterContentUseCase
    private let PRELOAD_PAGE_RANGE = 5
    
    var config: ReaderConfig = defaultConfig
    var currentPage: Int = 0 {
        didSet {
            
        }
    }
    var loadingProgress: [URL:Double] = [:]
    
    var displayOverlay: Bool
    
    init(
        fetchHostSourceMangaChapterContentUseCase: FetchHostSourceMangaChapterContentUseCase,
        chapter: Chapter
    ) {
        self.fetchHostSourceMangaChapterContentUseCase = fetchHostSourceMangaChapterContentUseCase
        self.chapter = chapter
        self.displayOverlay = true
    }
    
    func onOpen() {
        Task {
            try await getChapterContent()
        }
    }
    
    func cycleReadingDirection() {
        switch config.readerDirection {
        case .LTR:
            config.readerDirection = .RTL
        case .RTL:
            config.readerDirection = .Vertical
        case .Vertical:
            config.readerDirection = .Webtoon
        case .Webtoon:
            config.readerDirection = .LTR
        }
    }
    
    private func getChapterContent() async throws -> Void {
        chapterContent = try await fetchHostSourceMangaChapterContentUseCase.execute(
            host: ActiveHostManager.shared.getActiveHost(),
            source: ActiveHostManager.shared.getActiveSource(),
            chapter: chapter
        )
    }
}
