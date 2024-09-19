//
//  NetworkService+FetchSourceListManga.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation

extension NetworkService: FetchSourceListMangaProtocol {
    func fetchSourceListManga
    (
        host: Host,
        source: Source,
        path: String,
        page: Int = 0
    ) async throws -> [ListMangaDTO]
    {
        let url = try buildPagedURL(
            host: host,
            source: source,
            path: path,
            page: page
        )
        
        return try await request(url: url)
    }
}
