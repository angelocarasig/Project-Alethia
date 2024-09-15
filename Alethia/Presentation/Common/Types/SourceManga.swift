//
//  SourceManga.swift
//  Alethia
//
//  Created by Angelo Carasig on 14/9/2024.
//

import SwiftUI

@Observable
class SourceManga: Identifiable, Equatable {
    let id: String
    let title: String
    let coverUrl: String
    let origin: ListManga.Origin
    var inLibrary: Bool

    init(_ listManga: ListManga, inLibrary: Bool) {
        self.id = listManga.id
        self.title = listManga.title
        self.coverUrl = listManga.coverUrl
        self.origin = listManga.origin
        self.inLibrary = inLibrary
    }
    
    init(id: String, title: String, coverUrl: String, origin: ListManga.Origin, inLibrary: Bool) {
        self.id = id
        self.title = title
        self.coverUrl = coverUrl
        self.origin = origin
        self.inLibrary = inLibrary
    }

    func toListManga() -> ListManga {
        return ListManga(
            id: id,
            title: title,
            coverUrl: coverUrl,
            origin: .Remote
        )
    }

    // Equatable conformance for comparison
    static func == (lhs: SourceManga, rhs: SourceManga) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}
