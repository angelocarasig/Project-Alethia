//
//  MangaRepositoryImpl.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation
import RealmSwift

final class MangaRepositoryImplementation {
    private let local: MangaLocalDataSource
    private let remote: MangaRemoteDataSource
    
    init(local: MangaLocalDataSource, remote: MangaRemoteDataSource) {
        self.local = local
        self.remote = remote
    }
}

extension MangaRepositoryImplementation: MangaRepository {
    func observeMangaIds(ids: [String], callback: @escaping (String, Bool) -> Void) async -> RealmSwift.NotificationToken? {
        return await local.observeMangaIds(ids: ids, callback: callback)
    }

    func observeMangaDbChanges() async -> NotificationToken? {
        return await local.observeMangaDbChanges()
    }
    
    func addMangaToLibrary(_ manga: Manga) async -> Bool {
        return await local.addMangaToLibrary(RealmManga(manga))
    }
}
