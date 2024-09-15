//
//  SourceResult.swift
//  Alethia
//
//  Created by Angelo Carasig on 14/9/2024.
//

import Foundation

struct SourceResult: Identifiable, Equatable {
    var id: Int { index }
    
    var index: Int
    var name: String
    var path: String
    var results: [SourceManga]
}
