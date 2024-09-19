//
//  MangaRemoteDataSource.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation

final class MangaRemoteDataSource {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
}

extension MangaRemoteDataSource {
    func fetchChapterContent(host: Host, source: Source, chapter: Chapter) async throws -> [URL] {
        return try await networkService.getChapterContent(host: host, source: source, chapter: chapter)
    }
}
