//
//  RemoveHostUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import Foundation

protocol RemoveHostUseCase {
    func execute(_ host: Host) async
}

final class RemoveHostUseCaseImpl: RemoveHostUseCase {
    private let repo: HostRepository
    
    init(host: HostRepository) {
        self.repo = host
    }
    
    func execute(_ host: Host) async {
        await self.repo.removeHost(host)
    }
}
