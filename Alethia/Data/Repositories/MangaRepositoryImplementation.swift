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
    
    func observeLibraryManga(query: MangaQuery?, callback: @escaping ([LibraryManga]) -> Void) async -> NotificationToken? {
        return await local.observeLibraryManga(query: query, callback: callback)
    }
    
    func getOriginParents(_ origin: Origin) async -> (Host, Source)? {
        return await local.getOriginParents(origin)
    }
    
    func addMangaToLibrary(_ manga: Manga) async -> Void {
        await local.addMangaToLibrary(RealmManga(manga))
    }
    
    func removeMangaFromLibrary(_ manga: Manga) async -> Void {
        await local.removeMangaFromLibrary(manga)
    }
    
    func addOriginToMangaOrigins(manga: Manga, origin: Origin) async {
        await local.addOriginToMangaOrigins(manga: manga, origin: origin)
    }
    
    func fetchChapterContent(_ chapter: Chapter) async throws -> [URL] {
        if let activeHost = ActiveHostManager.shared.getActiveHost(),
           let activeSource = ActiveHostManager.shared.getActiveSource() {
            print("Using active host and source from manager...")
            return try await remote.fetchChapterContent(host: activeHost, source: activeSource, chapter: chapter)
        }
        
        print("Active Host Manager is unset. Fetching from Realm Chapter metadata...")
        
        guard let origin = await local.getChapterOrigin(chapter) else {
            print("Could not find an origin when fetching chapter content!")
            throw LocalError.notFound
        }
        
        print("Origin ID: ", origin.id)
        
        guard let source = await local.getChapterSource(origin) else {
            print("Could not find a source when fetching chapter content!")
            throw LocalError.notFound
        }
        
        print("Source ID: ", source.id)
        
        guard let host = await local.getChapterHost(source) else {
            print("Could not find a host when fetching chapter content!")
            throw LocalError.notFound
        }
        
        print("Host: ", host.name)
        
        return try await remote.fetchChapterContent(host: host, source: source, chapter: chapter)
    }
}
