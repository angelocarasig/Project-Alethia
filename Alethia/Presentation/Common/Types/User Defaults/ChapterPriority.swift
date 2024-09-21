//
//  ChapterPriority.swift
//  Alethia
//
//  Created by Angelo Carasig on 21/9/2024.
//

import Foundation

// Store in User-Defaults
enum ChapterPriority: Codable {
    // Naively return based on manga's origin array (each origin maps to a source)
    case firstSource
    
    // Return first chapter found based on the order of these source's IDs
    case biasedSource(sourceIDs: [String])
    
    private enum CodingKeys: String, CodingKey {
        case type
        case sourceIDs
    }
    
    private enum PriorityType: String, Codable {
        case firstSource
        case biasedSource
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(PriorityType.self, forKey: .type)
        
        switch type {
        case .firstSource:
            self = .firstSource
        case .biasedSource:
            let sourceIDs = try container.decode([String].self, forKey: .sourceIDs)
            self = .biasedSource(sourceIDs: sourceIDs)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .firstSource:
            try container.encode(PriorityType.firstSource, forKey: .type)
        case .biasedSource(let sourceIDs):
            try container.encode(PriorityType.biasedSource, forKey: .type)
            try container.encode(sourceIDs, forKey: .sourceIDs)
        }
    }
}
