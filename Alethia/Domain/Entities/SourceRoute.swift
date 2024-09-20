//
//  SourceRoute.swift
//  Alethia
//
//  Created by Angelo Carasig on 31/8/2024.
//

import Foundation

struct SourceRoute: Equatable, Hashable {
    /// Visual name of route used in display
    var name: String
    
    /// Route path used in network requests to the route
    var path: String
}
