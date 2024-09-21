//
//  ColorCacheManager.swift
//  Alethia
//
//  Created by Angelo Carasig on 19/9/2024.
//

import UIKit

// Used to determine 
final class ColorCacheManager {
    static let shared = ColorCacheManager()
    
    private init() {}
    
    private let cache = NSCache<NSURL, UIColor>()
    
    /// Retrieves the cached color for a given URL, if available.
    /// - Parameter url: The URL of the image.
    /// - Returns: The cached UIColor or nil if not found.
    func getColor(for url: URL) -> UIColor? {
        return cache.object(forKey: url as NSURL)
    }
    
    /// Caches the color for a given URL.
    /// - Parameters:
    ///   - color: The UIColor to cache.
    ///   - url: The URL of the image.
    func setColor(_ color: UIColor, for url: URL) {
        cache.setObject(color, forKey: url as NSURL)
    }
}
