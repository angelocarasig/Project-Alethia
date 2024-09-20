//
//  Host.swift
//  Alethia
//
//  Created by Angelo Carasig on 24/8/2024.
//

import Foundation

struct Host: Equatable, Identifiable {
    /// Unique ID
    var id: String { name }
    
    /// Visual name of source which also acts as the PKEY
    var name: String
    
    /// List of sources available for the repository
    var sources: Array<Source>
    
    /// Base URL
    var baseUrl: String
}
