//
//  UserDefaultsHelper.swift
//  Alethia
//
//  Created by Angelo Carasig on 21/9/2024.
//

import Foundation

final class UserDefaultsHelper {
    private init() {}
    
    static var shared = UserDefaultsHelper()
}

// MARK - ChapterPriority

extension UserDefaultsHelper {
    func saveChapterPriority(_ priority: ChapterPriority) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(priority) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultKeys.chapterPriority.rawValue)
        }
    }
    
    /// Defaults to first source if can't be found
    func getChapterPriority() -> ChapterPriority {
        if let savedData = UserDefaults.standard.object(forKey: UserDefaultKeys.chapterPriority.rawValue) as? Data {
            let decoder = JSONDecoder()
            if let loadedPriority = try? decoder.decode(ChapterPriority.self, from: savedData) {
                return loadedPriority
            }
        }
        
        return ChapterPriority.firstSource
    }
}
