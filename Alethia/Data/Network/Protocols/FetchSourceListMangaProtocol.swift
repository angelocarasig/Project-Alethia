//
//  FetchSourceListMangaProtocol.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation

protocol FetchSourceListMangaProtocol {
    func fetchSourceListManga(
        host: Host,
        source: Source,
        path: String,
        page: Int
    ) async throws -> [ListMangaDTO]
}
