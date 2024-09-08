//
//  SourceContentViewModel+Structs.swift
//  Alethia
//
//  Created by Angelo Carasig on 8/9/2024.
//

import Foundation

extension SourceContentViewModel {
    struct _SourceResult: Identifiable, Equatable {
        var id: Int { index }
        
        var index: Int
        var name: String
        var path: String
        var results: [SourceManga]
    }
    
    struct _SourceManga: Identifiable, Equatable {
        var id: String
        var title: String
        var coverUrl: String
        var origin: ListManga.Origin
        var inLibrary: Bool
        
        init(_ listManga: ListManga, inLibrary: Bool) {
            self.id = listManga.id
            self.title = listManga.title
            self.coverUrl = listManga.coverUrl
            self.origin = listManga.origin
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
    }
}
