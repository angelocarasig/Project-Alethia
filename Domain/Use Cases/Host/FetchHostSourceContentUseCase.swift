//
//  FetchHostSourceContent.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import Foundation

protocol FetchHostSourceContentUseCase {
    func execute(host: Host, source: Source, path: String, page: Int) async throws -> [ListManga]
}

final class FetchHostSourceContentImpl: FetchHostSourceContentUseCase {
    private let repo: HostRepository
    
    init(repo: HostRepository) {
        self.repo = repo
    }
    
    func execute(host: Host, source: Source, path: String, page: Int) async throws -> [ListManga] {
        return try await self.repo.fetchHostSourceContent(host: host, source: source, path: path, page: page)
    }
}
