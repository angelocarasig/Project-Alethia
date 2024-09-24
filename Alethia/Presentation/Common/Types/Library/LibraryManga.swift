//
//  LibraryManga.swift
//  Alethia
//
//  Created by Angelo Carasig on 24/9/2024.
//

import Foundation

struct LibraryManga: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let synopsis: String
    let coverUrl: String
    let origin: ListManga.Origin
    let contentStatus: ContentStatus
    
    let addedAt: Date
    
    let tags: Array<String>
    
    func toListManga() -> ListManga {
        return ListManga(id: id, title: title, coverUrl: coverUrl, origin: origin)
    }
}
