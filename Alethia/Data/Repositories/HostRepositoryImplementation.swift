//
//  HostRepositoryImpl.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation

final class HostRepositoryImplementation {
    private let local: HostLocalDataSource
    private let remote: HostRemoteDataSource
    
    init(local: HostLocalDataSource, remote: HostRemoteDataSource) {
        self.local = local
        self.remote = remote
    }
}

extension HostRepositoryImplementation: HostRepository {
    
    func testHost(_ url: String) async throws -> Host {
        let newHost = try await remote.testHost(url: url)
        
        return newHost
    }
    
    func addHost(_ host: Host) async throws {
        await local.addHost(RealmHost(host))
    }
    
    func removeHost(_ host: Host) async {
        await local.deleteHost(host)
    }
    
    func fetchHostSourceContent(host: Host, source: Source, path: String, page: Int) async throws -> [ListManga] {
        return try await remote.fetchHostSourceContent(host: host, source: source, path: path, page: page)
    }
    
    func fetchHostSourceManga(host: Host?, source: Source?, slug: String) async throws -> Manga {
        // Attempt to fetch from local storage first
        if let localManga = await local.getManga(slug: slug) {
            return localManga
        }
        
        guard let host = host, let source = source else {
            throw NetworkError.inactiveRepository
        }
        
        // If not found locally, fetch from remote
        return try await remote.fetchSourceManga(host: host, source: source, slug: slug)
    }
}
