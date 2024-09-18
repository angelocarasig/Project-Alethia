//
//  FetchSourceMangaChapterContent.swift
//  Alethia
//
//  Created by Angelo Carasig on 15/9/2024.
//

import Foundation

extension NetworkService: FetchSourceMangaChapterContentProtocol {
    func getChapterContent(host: Host, source: Source, chapter: Chapter) async throws -> [URL] {
        let url = try buildChapterURL(host: host, source: source, chapter: chapter)
        
        print("Fetching chapter content at url: \(url.absoluteString)")
        let result: [String] = try await request(url: url)
        
        return result.map { URL(string: $0)! }
    }
}
