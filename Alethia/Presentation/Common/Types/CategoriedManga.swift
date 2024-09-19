//
//  CategoriedManga.swift
//  Alethia
//
//  Created by Angelo Carasig on 19/9/2024.
//

import Foundation

struct CategoriedManga: Identifiable {
    var id: String
    let category: String
    let manga: [Manga]
}
