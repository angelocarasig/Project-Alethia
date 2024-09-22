//
//  AlternativeHostManager.swift
//  Alethia
//
//  Created by Angelo Carasig on 21/9/2024.
//

import Foundation

/// In Source Control, when a manga gets replaced with its local version (i.e. manga already in library)
/// We need to keep track of any 'aliases' it contains - a 1-to-1 mapping
/// This will clear every time
final class AlternativeHostManager {
    private var mappings: [String:String] = [:]
    
    static let shared = AlternativeHostManager()
    
    private init() { }
    
    func addAlternativeMapping(original: String, replacement: String) -> Void {
        mappings[replacement] = original
    }
    
    func findOriginalMapping(replacement: String) -> String? {
        print("findOriginalMapping called with replacement: '\(replacement)'")
        print("Current Mappings:")
        for (replacementKey, originalValue) in mappings {
            print("'\(replacementKey)' : '\(originalValue)'")
        }
        
        let original = mappings[replacement]
        if let original = original {
            print("Mapping found: '\(replacement)' maps to '\(original)'!")
        } else {
            print("No mapping found for '\(replacement)'...")
        }

        return mappings[replacement]
    }
    
    func clearMappings() -> Void {
        print("Cleared mappings")
        mappings = [:]
    }
}
