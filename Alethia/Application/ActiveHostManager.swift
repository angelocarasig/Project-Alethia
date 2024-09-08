//
//  ActiveHostManager.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import Foundation

final class ActiveHostManager {
    
    static let shared = ActiveHostManager()
    
    private var activeHost: Host?
    private var activeSource: Source?
    
    private init() {}
    
    func setActiveHost(host: Host, source: Source) {
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
        self.activeHost = nil
        self.activeSource = nil
    }
}
