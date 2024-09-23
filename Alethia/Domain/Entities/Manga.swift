//
//  Manga.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/8/2024.
//
import Foundation

/// Represents a presentation model for Manga object
struct Manga: Equatable {
    /// A unique identifier for the manga.
    let id: String
    
    /// The display title of the manga.
    let title: String
    
    /// Alternative titles for the manga, which may include localized titles, abbreviations, or other names.
    let alternativeTitles: Array<String>
    
    /// The name of the author who wrote the manga.
    let author: String
    
    /// The name of the artist who illustrated the manga.
    let artist: String
    
    /// A short synopsis or description of the manga's storyline or content.
    let synopsis: String
    
    /// The date and time when this manga was added to the user's library.
    let addedAt: Date
    
    /// The content rating of the manga, indicating its age appropriateness or maturity level (e.g., all ages, mature).
    let contentRating: ContentRating
    
    /// The current status of the manga, indicating whether it is ongoing, completed, or canceled.
    let contentStatus: ContentStatus
    
    /// The URL for the cover image of the manga.
    let coverUrl: String
    
    /// A list of tags or genres associated with the manga (e.g., action, romance, comedy).
    let tags: Array<String>
    
    /// A 1-to-many relation list of groups to categorize the manga.
    let groups: Array<Group>
    
    /// A list of sources registered for this manga.
    /// When an update is triggered, if a source throws a 404/410 error, the source gets detached from the source list of this manga.
    let origins: Array<Origin>
    
    static func == (lhs: Manga, rhs: Manga) -> Bool {
        lhs.id == rhs.id
    }
    
    func toLocalListManga() -> ListManga {
        return ListManga(
            id: id,
            title: title,
            coverUrl: coverUrl,
            origin: ListManga.Origin.Local
        )
    }
}
