//
//  FetchSourceManga.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import Foundation

extension NetworkService: FetchSourceMangaProtocol {
    func fetchSourceManga(host: Host, source: Source, slug: String) async throws -> MangaDTO {
        let url = try buildMangaURL(host: host, source: source, slug: slug)
        print("Making request to: \(url.absoluteString)")
        return try await request(url: url)
    }
}
