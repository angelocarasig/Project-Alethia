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
    var chapter: Chapter
    private var origins: [Origin]
    
    var nextChapter: Chapter?
    var previousChapter: Chapter?
    
    // Referer header to add to retryable-image
    var referer: String = ""
    
    var chapterContent: [URL] = []
    
    private var fetchChapterContentUseCase: FetchChapterContentUseCase
    private var getChapterRefererUseCase: GetChapterRefererUseCase
    private var getNextChapterUseCase: GetNextChapterUseCase
    private var getPreviousChapterUseCase: GetPreviousChapterUseCase
    
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
        getChapterRefererUseCase: GetChapterRefererUseCase,
        getNextChapterUseCase: GetNextChapterUseCase,
        getPreviousChapterUseCase: GetPreviousChapterUseCase,
        chapter: Chapter,
        origins: [Origin]
    ) {
        self.fetchChapterContentUseCase = fetchChapterContentUseCase
        self.getChapterRefererUseCase = getChapterRefererUseCase
        self.getNextChapterUseCase = getNextChapterUseCase
        self.getPreviousChapterUseCase = getPreviousChapterUseCase
        
        self.chapter = chapter
        self.origins = origins
        
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
            await referer = getChapterRefererUseCase.execute(chapter)
            await fetchAdjacentChapters()
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
        print("Fetching Chapter Content!")
        chapterContent = try await fetchChapterContentUseCase.execute(chapter)
        print("Chapter content has count \(chapterContent.count)!")
    }
    
    private func fetchAdjacentChapters() async {
        print("Fetching adjacent chapters...")
        do {
            print("Current Chapter is \(chapter.chapterNumber) - \(chapter.chapterTitle)")
            
            nextChapter = try await getNextChapterUseCase.execute(chapter: chapter, origins: origins)
            print("Next Chapter is \(nextChapter?.chapterNumber) - \(nextChapter?.chapterTitle)")
            
            previousChapter = try await getPreviousChapterUseCase.execute(chapter: chapter, origins: origins)
            print("Previous Chapter is \(previousChapter?.chapterNumber) - \(previousChapter?.chapterTitle)")
        } catch {
            print("Error fetching adjacent chapters: \(error)")
        }
    }
    
    func goToNextChapter() async {
        print("Going to next chapter...")
        guard let nextChapter = nextChapter else {
            print("No next chapter available.")
            return
        }
        
        // Update chapter synchronously
        chapter = nextChapter
        chapterContent = []
        
        do {
            try await getChapterContent()
            currentPage = 0 // Just set to first page
            await referer = getChapterRefererUseCase.execute(chapter)
            await fetchAdjacentChapters()
        } catch {
            print("Error navigating to next chapter: \(error)")
        }
    }
    
    func goToPreviousChapter() async {
        print("Going to previous chapter...")
        guard let previousChapter = previousChapter else {
            print("No previous chapter available.")
            return
        }
        
        // Update chapter synchronously
        chapter = previousChapter
        chapterContent = []
        
        do {
            try await getChapterContent()
            currentPage = chapterContent.count - 1 // Set to the last page of the previous chapter
            await referer = getChapterRefererUseCase.execute(chapter)
            await fetchAdjacentChapters()
        } catch {
            print("Error navigating to previous chapter: \(error)")
        }
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
            progressBlock: nil
        )
        imagePrefetcher?.start()
    }
    
    @objc private func handleMemoryWarning() {
        // Handle memory warning by clearing memory cache
        ImageCache.default.clearMemoryCache()
    }
}
