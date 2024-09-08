//
//  FetchSourceManga.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import Foundation

extension NetworkService: FetchSourceMangaProtocol {
    func fetchSourceManga(host: Host, source: Source, slug: String) async throws -> MangaDTO {
        let url = try buildMangaURL(repository: host, source: source, slug: slug)
        
        return try await request(url: url)
    }
}
