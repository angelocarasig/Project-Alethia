//
//  AddHostUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation

protocol AddHostUseCase {
    func execute(_ url: String) async throws
}

final class AddHostUseCaseImpl: AddHostUseCase {
    private let repo: HostRepository
    
    init(host: HostRepository) {
        self.repo = host
    }
    
    func execute(_ url: String) async throws {
        try await self.repo.addHost(url)
    }
}
