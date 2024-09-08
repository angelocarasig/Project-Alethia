//
//  HostDTO.swift
//  Illithia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation

struct HostDTO: Decodable {
    let repository: String
    let sources: Array<SourceItemDTO>
}

struct SourceItemDTO: Decodable {
    let source: String
    let path: String
}

struct SourceRoutesDTO: Decodable {
    let routes: Array<SourceRouteDTO>
}

struct SourceRouteDTO: Decodable {
    let name: String
    let path: String
}
