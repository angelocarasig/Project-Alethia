//
//  Origin.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/8/2024.
//

import Foundation

struct Origin {
    /// Unique Identifier for the source for the given manga.
    let id: String
    
    /// Refers to the repository name this source belongs to.
    let sourceId: String
    
    /// Refers to ID of the Manga object this source belongs to.
    let mangaId: String
    
    /// Unique string used in identifying how to request an update to that source in relation to the repository and source.
    let slug: String
    
    /// Last time the source for a given manga was updated (only changes when a new/edit occurrs in chapter list, not whenever it's fetched)
    let updatedAt: Date
    
    /// Date when the source has been associated with the given manga.
    let createdAt: Date
    
    /// URL pointing to the manga for this source.
    let url: String
    
    /// List of chapters items belonging to this source for its associated manga.
    let chapters: Array<Chapter>
}
