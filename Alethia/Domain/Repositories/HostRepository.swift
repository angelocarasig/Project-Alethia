//
//  HostRepository.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation

protocol HostRepository {
    /**
     Case -
     Test for host ->
     Host returned ->
     addHost passes in Host object and saves to local
     */
    func testHost(_ url: String) async throws -> Host
    func addHost(_ host: Host) async throws
    
    /**
     Case -
     Host objects retrieved ->
     on delete confirm, pass Host object in for removal
     */
    func removeHost(_ host: Host) async -> Void
    
    /**
     Case -
     On a given source, fetch its custom routes ->
     Should return [ListManga]
     */
    func fetchHostSourceContent(host: Host, source: Source, path: String, page: Int) async throws -> [ListManga]
    
    /// Pass in ListManga which contains an origin property that determines if its from local or remote.
    /// Use that value to fetch from local or remote.
    func fetchHostSourceManga(host: Host?, source: Source?, listManga: ListManga) async throws -> Manga
    
    /// Eh? Why another function similar to above? - above fetches from local first then remote, the one below will only fetch if host manager is on a source
    /// We don't care about anything else besides the slug similarly
    func fetchNewOriginData(host: Host, source: Source, slug: String) async throws -> OriginCellData
}
