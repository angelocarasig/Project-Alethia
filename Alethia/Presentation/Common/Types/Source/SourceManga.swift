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
    let slug: String // Keep track of the network fetched slug in case its used elsewhere
    let title: String
    let coverUrl: String
    let origin: ListManga.Origin
    var inLibrary: Bool

    /// A SourceManga requires careful management of the ID, Slug and Origin properties so that the app knows
    /// how exactly we this information:
    ///
    /// CASE 1
    /// ------------
    /// 1. SourceManga are typically initialized via a ListManga.
    /// 2. When initialized by a list manga, that ListManga most likely comes from a generated ListMangaDTO, which always
    /// maps its origin to .Remote hence we can just assign the origin to .Remote
    /// 3. We also assume that the first way to init a source manga has inLibrary set to false.
    /// 4. On initialization, it must always be remote - the ID must always be the slug - the extreme edge case is that it isn't and thus the slug is an empty string
    ///-------------
    ///
    ///Case 2
    ///-------------
    /// 1. A SourceManga can be initialized with all of its properties defined.
    /// 2. This is typically done through an observer handler (Realm Notification Token)
    /// 3. It processes a SourceManga generated in Case 1 and will re-map it based on the handled results
    /// 4. In the case that it's in library, the ID becomes the actual UUID - Otherwise it remains the slug and the slug continues to exist as a copy
    /// 5. If a manga gets added into library, the handler processes the source manga, notices that its in library and does the following:
    ///     a. Adjusts the ID to the RealmManga object ID
    ///     b. Adjusts inLibrary to true
    ///     c. The slug remains the existing value from the value when it was retrieved from Remote.
    ///
    /// 6. If a manga gets removed from library:
    ///     a. The ID is modified back to the slug
    ///     b. The inLibrary value is set to false
    ///     c. The slug remains the existing value from the value when it was retrieved from Remote.
    ///
    /// This approach essentially uses the `slug` property to act as a copy for when a manga is added/removed repetitively from the library.
    
    // # Case 1 - Source Manga initialized via ListManga (initialized from ListMangaDTO where origin is always .Remote)
    init(_ listManga: ListManga, inLibrary: Bool = false) {
        self.id = listManga.id
        self.slug = inLibrary ? "" : listManga.id
        self.title = listManga.title
        self.coverUrl = listManga.coverUrl
        self.origin = listManga.origin
        self.inLibrary = inLibrary
    }
    
    // # Case 2 - Source Manga initialized most liekyl via an Observer (Realm NotificationToken)
    init(
        id: String,
        slug: String,
        title: String,
        coverUrl: String,
        origin: ListManga.Origin,
        inLibrary: Bool
    )
    {
        self.id = id
        self.slug = id
        self.title = title
        self.coverUrl = coverUrl
        self.origin = origin
        self.inLibrary = inLibrary
    }

    // Used to pass into MangaCard prop allows it to not care about its origin
    func toListManga() -> ListManga {
        return ListManga(
            /// If the origin is local, the ID continues to be the ID as a precaution, and the slug becomes the ID otherwise.
            id: origin  == .Local ? id : slug,
            title: title,
            coverUrl: coverUrl,
            origin: origin
        )
    }
    
    // To conform to Equatable
    static func == (lhs: SourceManga, rhs: SourceManga) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}
