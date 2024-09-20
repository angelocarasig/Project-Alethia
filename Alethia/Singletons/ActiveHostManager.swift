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
        didSet {
            print("Active Host changed to \(activeHost?.name)")
        }
    }
    private var activeSource: Source? {
        didSet {
            print("Active Source changed to \(activeSource?.name)")
        }
    }
    
    private init() {}
    
    func setActiveHost(host: Host, source: Source) {
        self.activeHost = host
        self.activeSource = source
        
        // We need to reset alternative host manager whenever active host changes
        let previous = AlternativeHostManager.shared.getPreviousHostSource()
       
        // Don't clear if previous is empty
        if previous.0 == nil || previous.1 == nil { return }
        
        // Don't clear if current is empty
        if activeHost == nil || activeSource == nil { return }
        
        // Don't clear if previous is still current
        if previous.0 == activeHost && previous.1 == activeSource { return }
        
        AlternativeHostManager.shared.clearMappings()
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
