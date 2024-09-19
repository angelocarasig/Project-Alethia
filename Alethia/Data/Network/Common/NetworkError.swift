//
//  NetworkError.swift
//  Alethia
//
//  Created by Angelo Carasig on 3/9/2024.
//

import Foundation

enum NetworkError: Error {
    case missingURL
    case noConnect
    case invalidData
    case requestFailed
    case encodingError
    case decodingError
    case invalidResponse
    case inactiveRepository
    
    var errorDescription: String? {
        switch self {
        case .missingURL:
            return "Missing URL."
        case .noConnect:
            return "No connection."
        case .invalidResponse:
            return "Invalid response from server."
        case .invalidData:
            return "Invalid data received."
        case .decodingError:
            return "Failed to decode data."
        case .encodingError:
            return "Failed to encode data."
        case .requestFailed:
            return "Network request failed."
        case .inactiveRepository:
            return "Repository + Source is inactive (Did you fetch from somewhere where repository isn't set?)"
        }
    
    }
}
