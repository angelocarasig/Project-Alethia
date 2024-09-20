//
//  DimensionsCache.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import SwiftUI

final class DimensionsCache {
    static let shared = DimensionsCache()
    
    private init() {}
    
    private(set) var dimensions: (width: CGFloat, height: CGFloat) = {
        if UIDevice.current.userInterfaceIdiom == .pad || UIScreen.main.bounds.width > 400 {
            return calculateDimensions(forHeight: 185)  // iPhone Max and iPad size
        }
        
        return calculateDimensions(forHeight: 165)  // Regular iPhone size
    }()
    
    // Helper method to calculate width as 11/16 of the height
    private static func calculateDimensions(forHeight height: CGFloat) -> (width: CGFloat, height: CGFloat) {
        let width = height * (11.0 / 16.0)
        return (width, height)
    }
}
