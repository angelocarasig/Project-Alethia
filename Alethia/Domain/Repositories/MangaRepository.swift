//
//  MangaRepository.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation
import RealmSwift

protocol MangaRepository {
    // Observers
    func observeSourceManga(
        roots: [SourceResult],
        paths: [SourceManga],
        callback: @escaping([SourceResult], [SourceManga]) -> Void
    ) async -> NotificationToken?
    
    func observeManga(manga: Manga, callback: @escaping (MangaEvent) -> Void) async -> NotificationToken?
    
    func observeLibraryManga(callback: @escaping ([Manga]) -> Void) async -> NotificationToken?
    
    // CRUD
    func addMangaToLibrary(_ manga: Manga) async -> Void
    
    func removeMangaFromLibrary(_ manga: Manga) async -> Void
    
    // Actions
    func fetchChapterContent(_ chapter: Chapter) async throws -> [URL]
}