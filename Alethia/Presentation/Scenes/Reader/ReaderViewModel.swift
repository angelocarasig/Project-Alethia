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
    let chapter: Chapter
    var chapterContent: [URL] = []
    
    private var fetchChapterContentUseCase: FetchChapterContentUseCase
    
    private var imagePrefetcher: ImagePrefetcher?
    private let prefetchRange = 5 // Number of images to prefetch before and after current page
    
    var config: ReaderConfig = defaultConfig
    var currentPage: Int = 0 {
        didSet {
            prefetchImages()
        }
    }
    var loadingProgress: [URL: Double] = [:]
    
    var displayOverlay: Bool
    
    init(
        fetchChapterContentUseCase: FetchChapterContentUseCase,
        chapter: Chapter
    ) {
        self.fetchChapterContentUseCase = fetchChapterContentUseCase
        self.chapter = chapter
        self.displayOverlay = true
    }
    
    deinit {
        // Remove observer and cancel any ongoing prefetching tasks
        NotificationCenter.default.removeObserver(self)
        imagePrefetcher?.stop()
    }
    
    func onOpen() {
        Task {
            try await getChapterContent()
            prefetchImages() // Start prefetching after content is loaded
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
    
    private func getChapterContent() async throws {
        chapterContent = try await fetchChapterContentUseCase.execute(chapter)
    }
    
    private func prefetchImages() {
        // Cancel any ongoing prefetching tasks
        imagePrefetcher?.stop()
        
        guard !chapterContent.isEmpty else { return }
        
        // Calculate the range of indices to prefetch
        let startIndex = max(0, currentPage - prefetchRange)
        let endIndex = min(chapterContent.count - 1, currentPage + prefetchRange)
        
        // If there are no new images to prefetch, return early
        guard startIndex <= endIndex else { return }
        
        let urlsToPrefetch = Array(chapterContent[startIndex...endIndex])
        
        // Create and start the prefetcher with options
        imagePrefetcher = ImagePrefetcher(
            urls: urlsToPrefetch,
            options: [.cacheOriginalImage],
            progressBlock: nil,
            completionHandler: { skippedResources, failedResources, completedResources in
                print("Prefetched images: \(completedResources.count)")
            }
        )
        imagePrefetcher?.start()
    }
    
    @objc private func handleMemoryWarning() {
        // Handle memory warning by clearing memory cache
        ImageCache.default.clearMemoryCache()
    }
}
