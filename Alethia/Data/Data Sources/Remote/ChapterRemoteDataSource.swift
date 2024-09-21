//
//  ChapterRemoteDataSource.swift
//  Alethia
//
//  Created by Angelo Carasig on 21/9/2024.
//

import Foundation
@preconcurrency import RealmSwift

final class ChapterRemoteDataSource {
    func getChapterReferer(_ chapter: Chapter) async -> String {
        guard let activeHost = ActiveHostManager.shared.getActiveSource() else { return "" }
        
        return activeHost.referer
    }
}
