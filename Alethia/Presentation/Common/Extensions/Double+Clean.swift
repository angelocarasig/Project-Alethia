//
//  Double+Clean.swift
//  Alethia
//
//  Created by Angelo Carasig on 7/9/2024.
//

import Foundation

extension Double {
    var clean: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
