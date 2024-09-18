//
//  FetchSourceMangaChapterContentProtocol.swift
//  Alethia
//
//  Created by Angelo Carasig on 15/9/2024.
//

import Foundation

protocol FetchSourceMangaChapterContentProtocol {
    func getChapterContent(host: Host, source: Source, chapter: Chapter) async throws -> [URL]
}
