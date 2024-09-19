//
//  FetchHostSourceMangaUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import Foundation

protocol FetchHostSourceMangaUseCase {
    func execute(host: Host?, source: Source?, listManga: ListManga) async throws -> Manga
}

final class FetchHostSourceMangaImpl: FetchHostSourceMangaUseCase {
    private let repo: HostRepository
    
    init(repo: HostRepository) {
        self.repo = repo
    }
    
    func execute(host: Host?, source: Source?, listManga: ListManga) async throws -> Manga {
        return try await self.repo.fetchHostSourceManga(host: host, source: source, listManga: listManga)
    }
}
