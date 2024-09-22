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
        AlternativeHostManager.shared.clearMappings()
        
        self.activeHost = host
        self.activeSource = source
    }
    
    func getActiveHost() -> Host? {
        return activeHost
    }
    
    func getActiveSource() -> Source? {
        return activeSource
    }
    
    func clearActiveHost() {
        AlternativeHostManager.shared.clearMappings()
        self.activeHost = nil
        self.activeSource = nil
    }
    
    func hasActiveHost() -> Bool {
        return self.activeHost != nil && self.activeSource != nil
    }
}
