//
//  Chapter.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/8/2024.
//

import Foundation

struct Chapter: Hashable {
    /// Refers directly to the origin this chapter's related to's ID
    let originId: String
    
    /// Unique string used to be able to fetch chapter contents for the given repository + source
    let slug: String
    
    /// Refers to the manga's slug to be able to fetch chapter contents
    let mangaSlug: String
    
    /// Chapter Number
    let chapterNumber: Double
    
    /// Chapter Title (can be empty string)
    let chapterTitle: String
    
    /// More related to scanlation group but if unknown, will be set to the source's name the chapter belongs to
    let author: String
    
    /// Date of chapter release
    let date: Date
    
    /// For convenience
    func toString() -> String {
        return "Chapter \(chapterNumber.clean) \(chapterTitle.isEmpty ? "" : "-\(chapterTitle)")"
    }
}
