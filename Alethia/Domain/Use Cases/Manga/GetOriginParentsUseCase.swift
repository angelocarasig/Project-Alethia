//
//  GetOriginParentsUseCase.swift
//  Alethia
//
//  Created by Angelo Carasig on 20/9/2024.
//

import Foundation

protocol GetOriginParentsUseCase {
    func execute(_ origin: Origin) async -> (Host, Source)?
}

final class GetOriginParentsImpl: GetOriginParentsUseCase {
    private let repo: MangaRepository
    
    init(repo: MangaRepository) {
        self.repo = repo
    }
    
    func execute(_ origin: Origin) async -> (Host, Source)? {
        return await repo.getOriginParents(origin)
    }
}
