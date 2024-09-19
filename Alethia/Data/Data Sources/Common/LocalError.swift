//
//  LocalError.swift
//  Alethia
//
//  Created by Angelo Carasig on 19/9/2024.
//

import Foundation

enum LocalError: Error {
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Could not find the given realm object."
        }
    }
}
