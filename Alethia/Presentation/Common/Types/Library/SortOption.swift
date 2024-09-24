//
//  SortOption.swift
//  Alethia
//
//  Created by Angelo Carasig on 23/9/2024.
//

import Foundation

enum SortOption: String, CaseIterable {
    case title = "Title"
    case addedAt = "Date Added"
    case updatedAt = "Date Updated"
    case lastReadAt = "Last Read At"
    
    // Used in querying
    var keyPath: String {
        switch self {
        case .title:
            return "title"
        
        //TTODO: Expand this
        case .addedAt, .updatedAt, .lastReadAt:
            return "addedAt"
        }
    }
}
