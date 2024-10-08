//
//  HostRepositoryImpl.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation

final class HostRepositoryImplementation {
    private let local: HostLocalDataSource
    private let remote: HostRemoteDataSource
    
    init(local: HostLocalDataSource, remote: HostRemoteDataSource) {
        self.local = local
        self.remote = remote
    }
}

extension HostRepositoryImplementation: HostRepository {
    
    func testHost(_ url: String) async throws -> Host {
        let newHost = try await remote.testHost(url: url)
        
        return newHost
    }
    
    func addHost(_ host: Host) async throws {
        await local.addHost(RealmHost(host))
    }
    
    func removeHost(_ host: Host) async {
        await local.deleteHost(host)
    }
    
    func fetchHostSourceContent(host: Host, source: Source, path: String, page: Int) async throws -> [ListManga] {
        return try await remote.fetchHostSourceContent(host: host, source: source, path: path, page: page)
    }
    
    func fetchHostSourceManga(host: Host?, source: Source?, listManga: ListManga) async throws -> Manga {
        // Attempt to fetch from local storage first
        if let localManga = await local.getManga(listManga: listManga) {
            print("Fetched from Local!")
            return localManga
        }
        
        // Must have a valid host or source to fetch from remote
        guard let host = host, let source = source else {
            throw NetworkError.inactiveRepository
        }
        
        // If not found locally, fetch from remote
        print("Fetched from Remote!")
        return try await remote.fetchSourceManga(host: host, source: source, listManga: listManga)
    }
    
    func fetchHostSourceMangaChapterContent(host: Host?, source: Source?, chapter: Chapter) async throws -> [URL] {
        guard let host = host, let source = source else {
            throw NetworkError.inactiveRepository
        }
        
        print("Host and manager unavailable (request coming from a non-sources tab), fetching via chapter metadata...")
        do {
            let localContent = try await local.getChapterContent(host: host, source: source, chapter: chapter)
            
            if !localContent.isEmpty {
                return localContent
            }
        } catch {
            print("Failed to fetch local content: \(error). Fetching from remote.")
        }
        
        print("Could not fetch chapter content from local data source... fetching from remote...")
        return try await remote.getChapterContent(host: host, source: source, chapter: chapter)
    }
    
    func fetchNewOriginData(host: Host, source: Source, slug: String) async throws -> OriginCellData {
        return try await remote.fetchNewOriginData(host: host, source: source, slug: slug)
    }
}
