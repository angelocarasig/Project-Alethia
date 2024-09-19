//
//  HostRemoteDataSource.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation

final class HostRemoteDataSource {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
}

extension HostRemoteDataSource {
    func testHost(url: String) async throws -> Host {
        return try await networkService.testHost(url: url)
    }
    
    func fetchHostSourceContent(host: Host, source: Source, path: String, page: Int) async throws -> [ListManga] {
        return try await networkService.fetchSourceListManga(
            host: host,
            source: source,
            path: path,
            page: page
        )
        .map { $0.toDomain() }
    }
    
    func fetchSourceManga(host: Host, source: Source, listManga: ListManga) async throws -> Manga {
        guard listManga.origin == .Remote else { throw NetworkError.invalidData }
        
        return try await networkService.fetchSourceManga(
            host: host,
            source: source,
            slug: listManga.id
        )
        .toDomain()
    }
    
    func getChapterContent(host: Host, source: Source, chapter: Chapter) async throws -> [URL] {
        return try await networkService.getChapterContent(host: host, source: source, chapter: chapter)
    }
}
