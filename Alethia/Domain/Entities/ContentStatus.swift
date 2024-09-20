//
//  ContentStatus.swift
//  Aletheia
//
//  Created by Angelo Carasig on 24/8/2024.
//

import Foundation
import RealmSwift

enum ContentStatus: String, Codable, PersistableEnum {
    case ongoing = "Ongoing"
    case hiatus = "Hiatus"
    case cancelled = "Cancelled"
    case completed = "Completed"
}
