//
//  ListManga.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation

struct ListManga: Equatable, Identifiable, Hashable {
    enum Origin {
        case Remote
        case Local
    }
    
    /// Unique identifier for the manga.
    /// If retrieved from remote, this will be the manga slug to be used with the active repository.
    /// If retrieved from local, this will be the manga's ID.
    let id: String
    
    /// The display name/title of the manga.
    let title: String
    
    /// URL for the cover image of the manga.
    let coverUrl: String
    
    /// Source of the manga, either from a repository or the user's library.
    let origin: Origin
}
