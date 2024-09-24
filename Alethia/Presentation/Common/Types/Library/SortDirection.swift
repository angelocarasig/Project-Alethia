//
//  SortDirection.swift
//  Alethia
//
//  Created by Angelo Carasig on 23/9/2024.
//

import Foundation

enum SortDirection {
    case ascending
    case descending
    
    var isAscending: Bool {
        switch self {
        case .ascending:
            return true
        case .descending:
            return false
        }
    }
}
