//
//  Search.swift
//  Alethia
//
//  Created by Angelo Carasig on 21/9/2024.
//

import Foundation

struct Search {
    let query: String
    let inclusions: [SearchInclusion]
    let sort: SearchSort
    let status: SearchStatus
}

struct SearchBuilder {
    var query: String
    var inclusions: [SearchInclusion]
    var sort: [SearchSort]
    var status: [SearchStatus]
}

struct SearchInclusion {
    let name: String
    let value: String
    let included: Bool
}

struct SearchSort {
    let name: String
    let value: String
}

struct SearchStatus {
    let name: String
    let value: String
}
