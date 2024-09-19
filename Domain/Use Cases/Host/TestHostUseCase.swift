//
//  TestHostUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import Foundation

protocol TestHostUseCase {
    func execute(_ url: String) async throws -> Host
}

final class TestHostUseCaseImpl: TestHostUseCase {
    private let repo: HostRepository
    
    init(repo: HostRepository) {
        self.repo = repo
    }
    
    func execute(_ url: String) async throws -> Host {
        return try await self.repo.testHost(url)
    }
}
