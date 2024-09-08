//
//  ListMangaDTO.swift
//  Illithia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation

// DTO for Manga returned from a list
struct ListMangaDTO: Decodable {
    var sourceId: String
    var slug: String
    var title: String
    var coverUrl: String
    
    func toDomain() -> ListManga {
        return ListManga(
            id: slug,
            title: title,
            coverUrl: coverUrl,
            origin: ListManga.Origin.Remote
        )
    }
}
