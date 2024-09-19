//
//  MangaRepositoryImpl.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation
import RealmSwift

final class MangaRepositoryImplementation {
    private let local: MangaLocalDataSource
    private let remote: MangaRemoteDataSource
    
    init(local: MangaLocalDataSource, remote: MangaRemoteDataSource) {
        self.local = local
        self.remote = remote
    }
}

extension MangaRepositoryImplementation: MangaRepository {
    func observeSourceManga(roots: [SourceResult], paths: [SourceManga], callback: @escaping ([SourceResult], [SourceManga]) -> Void) async -> RealmSwift.NotificationToken? {
        return await local.observeSourceManga(roots: roots, paths: paths, callback: callback)
    }
    
    func observeManga(manga: Manga, callback: @escaping (MangaEvent) -> Void) async -> NotificationToken? {
        return await local.observeManga(manga: manga, callback: callback)
    }
    
    func observeLibraryManga(callback: @escaping ([Manga]) -> Void) async -> NotificationToken? {
        return await local.observeLibraryManga(callback: callback)
    }
    
    func addMangaToLibrary(_ manga: Manga) async -> Void {
        await local.addMangaToLibrary(RealmManga(manga))
    }
    
    func removeMangaFromLibrary(_ manga: Manga) async -> Void {
        await local.removeMangaFromLibrary(manga)
    }
    
    func fetchChapterContent(_ chapter: Chapter) async throws -> [URL] {
        guard let origin = await local.getChapterOrigin(chapter) else {
            print("Could not find an origin when fetching chapter content!")
            throw LocalError.notFound
        }
        
        print("Origin: ", origin)
        
        guard let source = await local.getChapterSource(origin) else {
            print("Could not find a source when fetching chapter content!")
            throw LocalError.notFound
        }
        
        print("Source: ", source)
        
        guard let host = await local.getChapterHost(source) else {
            print("Could not find a host when fetching chapter content!")
            throw LocalError.notFound
        }
        
        print("Host: ", host)
        
        return try await remote.fetchChapterContent(host: host, source: source, chapter: chapter)
    }
}
