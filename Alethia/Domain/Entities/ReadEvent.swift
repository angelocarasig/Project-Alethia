//
//  ReadEvent.swift
//  Alethia
//
//  Created by Angelo Carasig on 22/9/2024.
//

import Foundation

/// Handles which chapters have been read from a manga.
/// Each event represents a single 'read' action
///
/// 1. I as a user want to view which chapters i've "read" in the global chapter list:
/// - Perform lookup for all read status' for the manga
/// - Display 'read' for each chapter number found
///
/// 2. I as a user want to view which chapters i've actually read for a specific manga's source:
/// - Perform lookup all readEvents for the manga ID
/// - For each:
///     display 'read' if the given chapter number is found
///     display 'marked' if the chapter was read but not for the given origin's ID
///     don't display anything if chapter number can't be found
///
/// 3. I as a user want to set chapters in a range as read:
/// - for each chapter number selected check if a read event exists for the given manga ID
/// - if a read event exists with the same mangaId, originId and chapterId, update it's readAt date
/// - If a read event doesn't exist, make a new one for the given mangaId, originId and chapterId
///
/// 4. I as a user want to view my recently read manga:
/// - Query all read events by date, find unique manga Ids and return the manga objects
///
/// 5. I as a user want to unread a chapter in the global chapter list:
/// - Delete all corresponding read events for the given chapter number for the given manga ID
///
/// 6. I as a user want to unread a chapter for a given origin:
/// - Delete all corresponding read events for the given chapter number for the given origin ID
///
struct ReadEvent: Equatable, Identifiable, Hashable {
    let id: String // Indexed
    let mangaId: String // Indexed
    let originId: String // Indexed when looking up a specific origin
    let chapterId: String // Not indexed
    
    let chapterNumber: Double // Indexed
    let readAt: Date
}
