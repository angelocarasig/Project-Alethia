//
//  Source.swift
//  Alethia
//
//  Created by Angelo Carasig on 25/8/2024.
//

import Foundation

struct Source: Equatable, Identifiable {
    ///Unique ID for a source
    let id: String
    
    /// Display name of source for a repository
    let name: String
    
    /// Path to the source for the given repository
    let path: String
    
    /// Custom routes available for the route
    let routes: Array<SourceRoute>
    
    /// If multiple repositories contain the same source (i.e. Komga), an enabled option is present to use what's preferred
    let enabled: Bool
}
