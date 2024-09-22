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
    
    private var previousHost: Host?
    private var previousSource: Source?
    
    static let shared = AlternativeHostManager()
    
    private init() { }
    
    func addAlternativeMapping(original: String, replacement: String) -> Void {
        print("Added new mapping where '\(replacement)' points to '\(original)'")
        mappings[replacement] = original
    }
    
    func findOriginalMapping(replacement: String) -> String? {
        return mappings[replacement]
    }
    
    func clearMappings() -> Void {
        print("Cleared mappings")
        mappings = [:]
    }
    
    func setPreviousHost(host: Host?) {
        print("Set previous host to \(host?.name)")
        previousHost = host
    }
    
    func setPreviousSource(source: Source?) {
        print("Set previous source to \(source?.name)")
        previousSource = source
    }
    
    func getPreviousHostSource() -> (Host?, Source?) {
        return (previousHost, previousSource)
    }
}
