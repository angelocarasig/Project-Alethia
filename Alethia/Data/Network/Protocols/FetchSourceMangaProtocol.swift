//
//  FetchSourceMangaProtocol.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import Foundation

protocol FetchSourceMangaProtocol {
    func fetchSourceManga(host: Host, source: Source, slug: String) async throws -> MangaDTO
}
