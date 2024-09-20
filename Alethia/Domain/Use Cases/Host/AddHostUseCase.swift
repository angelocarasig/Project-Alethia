//
//  AddHostUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import Foundation

protocol AddHostUseCase {
    func execute(_ host: Host) async throws
}

final class AddHostUseCaseImpl: AddHostUseCase {
    private let repo: HostRepository
    
    init(host: HostRepository) {
        self.repo = host
    }
    
    func execute(_ host: Host) async throws {
        return try await self.repo.addHost(host)
    }
}
