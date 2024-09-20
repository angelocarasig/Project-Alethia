//
//  FetchNewOriginDataUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 20/9/2024.
//

import Foundation

protocol FetchNewOriginDataUseCase {
    func execute(host: Host, source: Source, slug: String) async throws -> OriginCellData
}

final class FetchNewOriginDataImpl: FetchNewOriginDataUseCase {
    private let repo: HostRepository
    
    init(repo: HostRepository) {
        self.repo = repo
    }
    
    func execute(host: Host, source: Source, slug: String) async throws -> OriginCellData {
        return try await repo.fetchNewOriginData(host: host, source: source, slug: slug)
    }
}
