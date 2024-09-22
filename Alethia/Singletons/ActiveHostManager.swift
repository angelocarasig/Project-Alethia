//
//  ActiveHostManager.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import Foundation

final class ActiveHostManager {
    
    static let shared = ActiveHostManager()
    
    private var activeHost: Host? {
        willSet {
            AlternativeHostManager.shared.setPreviousHost(host: activeHost)
        }
        didSet {
            print("Active Host changed to \(activeHost?.name)")
        }
    }
    private var activeSource: Source? {
        willSet {
            AlternativeHostManager.shared.setPreviousSource(source: activeSource)
        }
        didSet {
            print("Active Source changed to \(activeSource?.name)")
        }
    }
    
    private init() {}
    
    func setActiveHost(host: Host, source: Source) {
        self.activeHost = host
        self.activeSource = source
        
        /// TODO: Fix bug where:
        /// Go to manga (origin #1)
        /// Go back to sources, go to same manga (origin #2)
        /// Add manga (origin #2)
        /// Go back  to manga (origin #1)
        /// Log --> https://pastebin.com/mqG5Rums
        
        // We need to reset alternative host manager whenever active host changes
        let previous = AlternativeHostManager.shared.getPreviousHostSource()
        
        // Don't clear if previous is empty
        if previous.0 == nil || previous.1 == nil {
            print("Previous Host/Source is nil. Not clearing mappings...")
            return
        }
        
        // Don't clear if current is empty
        if activeHost == nil || activeSource == nil {
            print("Active Host/Source is nil. Not clearing mappings...")
            return
        }
        
        // If either changes, clear mappings
        if previous.0 == activeHost || previous.1 == activeSource {
            print("Clearing alt mappings...")
            
            AlternativeHostManager.shared.clearMappings()
        }
    }
    
    func getActiveHost() -> Host? {
        return activeHost
    }
    
    func getActiveSource() -> Source? {
        return activeSource
    }
    
    func clearActiveHost() {
        self.activeHost = nil
        self.activeSource = nil
    }
    
    func hasActiveHost() -> Bool {
        return self.activeHost != nil && self.activeSource != nil
    }
}
