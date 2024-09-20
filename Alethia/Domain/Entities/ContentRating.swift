//
//  ContentRating.swift
//  Aletheia
//
//  Created by Angelo Carasig on 24/8/2024.
//

import Foundation
import RealmSwift

enum ContentRating: String, Codable, PersistableEnum {
    case unknown = "Unknown"
    case safe = "Safe"
    case suggestive = "Suggestive"
    case explicit = "Explicit"
}
