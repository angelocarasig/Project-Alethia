//
//  MangaEvent.swift
//  Alethia
//
//  Created by Angelo Carasig on 15/9/2024.
//

import Foundation

enum MangaEvent {
    case inLibrary(Bool)
    // If source is present and something changed we should update
    case sourcePresent(Bool, Manga?)
    case errorOccurred(String)
}
