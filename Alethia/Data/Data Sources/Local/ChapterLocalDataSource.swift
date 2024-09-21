//
//  ChapterLocalDataSource.swift
//  Alethia
//
//  Created by Angelo Carasig on 21/9/2024.
//

import Foundation
@preconcurrency import RealmSwift

final class ChapterLocalDataSource {
    
    private let mangaLocalDataSource = MangaLocalDataSource()
    
    @RealmActor
    func getChapterReferer(_ chapter: Chapter) async throws -> String {
        guard let origin = await mangaLocalDataSource.getChapterOrigin(chapter) else {
            throw LocalError.notFound
        }
        
        guard let source = await mangaLocalDataSource.getChapterSource(origin) else {
            throw LocalError.notFound
        }
        
        return source.referer
    }
    
    /// Retrieves the next chapter based on the current chapter number and user-defined priority.
    ///
    /// This function identifies the smallest chapter number greater than the current chapter across all origins.
    /// It respects the user's priority settings:
    /// - `.firstSource`: Processes origins in their listed order, selecting the closest valid chapter.
    /// - `.biasedSource`: Processes origins based on a specified order (`sourceIDs`), selecting the closest valid chapter accordingly.
    ///
    /// If multiple origins contain chapters with the same valid chapter number, the origin processed first based on priority is selected.
    /// If no valid next chapter is found across all origins, the function returns `nil`.
    ///
    /// - Parameter chapter: The current `Chapter` from which to find the next chapter.
    /// - Returns: The next `Chapter` if found; otherwise, `nil`.
    /// - Throws: `LocalError.notFound` if origins or manga data cannot be retrieved.
    func getNextChapter(chapter: Chapter, origins: [Origin]) async throws -> Chapter? {
        let priority = UserDefaultsHelper.shared.getChapterPriority()
        
        switch priority {
        case .firstSource:
            var nextChapter: Chapter? = nil
            var minChapterNumber: Double = Double.greatestFiniteMagnitude
            
            for origin in origins {
                let candidateChapters = origin.chapters.filter { $0.chapterNumber > chapter.chapterNumber }
                
                if let candidate = candidateChapters.min(by: { $0.chapterNumber < $1.chapterNumber }) {
                    if candidate.chapterNumber < minChapterNumber {
                        minChapterNumber = candidate.chapterNumber
                        nextChapter = candidate
                    }
                }
            }
            return nextChapter
            
        case .biasedSource(let sourceIDs):
            var nextChapter: Chapter? = nil
            var minChapterNumber: Double = Double.greatestFiniteMagnitude
            
            for sourceID in sourceIDs {
                if let origin = origins.first(where: { $0.sourceId == sourceID }) {
                    let candidateChapters = origin.chapters.filter { $0.chapterNumber > chapter.chapterNumber }
                    
                    if let candidate = candidateChapters.min(by: { $0.chapterNumber < $1.chapterNumber }) {
                        if candidate.chapterNumber < minChapterNumber {
                            minChapterNumber = candidate.chapterNumber
                            nextChapter = candidate
                        }
                    }
                }
            }
            return nextChapter
        }
    }
    
    /// Retrieves the previous chapter based on the current chapter number and user-defined priority.
    ///
    /// This function identifies the largest chapter number less than the current chapter but not more than 2 chapters behind.
    /// Specifically, it considers chapters within the range `[floor(currentChapterNumber) - 1.0, currentChapterNumber)`.
    /// It respects the user's priority settings:
    /// - `.firstSource`: Processes origins in their listed order, selecting the closest valid chapter.
    /// - `.biasedSource`: Processes origins based on a specified order (`sourceIDs`), selecting the closest valid chapter accordingly.
    ///
    /// If multiple origins contain chapters with the same valid chapter number, the origin processed first based on priority is selected.
    /// If no valid previous chapter is found across all origins, the function returns `nil`.
    ///
    /// - Parameter chapter: The current `Chapter` from which to find the previous chapter.
    /// - Returns: The previous `Chapter` if found; otherwise, `nil`.
    /// - Throws: `LocalError.notFound` if origins or manga data cannot be retrieved.
    func getPreviousChapter(chapter: Chapter, origins: [Origin]) async throws -> Chapter? {
        let priority = UserDefaultsHelper.shared.getChapterPriority()
        
        // Calculate the lower bound using floor
        let lowerBound = floor(chapter.chapterNumber) - 1.0
        
        switch priority {
        case .firstSource:
            var previousChapter: Chapter? = nil
            var maxChapterNumber: Double = -Double.greatestFiniteMagnitude
            
            for origin in origins {
                let candidateChapters = origin.chapters.filter {
                    $0.chapterNumber >= lowerBound &&
                    $0.chapterNumber < chapter.chapterNumber
                }
                
                if let candidate = candidateChapters.max(by: { $0.chapterNumber < $1.chapterNumber }) {
                    if candidate.chapterNumber > maxChapterNumber {
                        maxChapterNumber = candidate.chapterNumber
                        previousChapter = candidate
                    }
                }
            }
            return previousChapter
            
        case .biasedSource(let sourceIDs):
            var previousChapter: Chapter? = nil
            var maxChapterNumber: Double = -Double.greatestFiniteMagnitude
            
            for sourceID in sourceIDs {
                if let origin = origins.first(where: { $0.sourceId == sourceID }) {
                    let candidateChapters = origin.chapters.filter {
                        $0.chapterNumber >= lowerBound &&
                        $0.chapterNumber < chapter.chapterNumber
                    }
                    
                    if let candidate = candidateChapters.max(by: { $0.chapterNumber < $1.chapterNumber }) {
                        if candidate.chapterNumber > maxChapterNumber {
                            maxChapterNumber = candidate.chapterNumber
                            previousChapter = candidate
                        }
                    }
                }
            }
            return previousChapter
        }
    }
    
}
