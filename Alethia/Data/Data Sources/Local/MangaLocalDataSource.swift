//
//  MangaLocalDataSource.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation
@preconcurrency import RealmSwift

final class MangaLocalDataSource {
    
    private let realmProvider = RealmProvider()
    
    @RealmActor
    func getManga(name: String) async -> RealmManga? {
        guard let storage = await realmProvider.realm() else { return nil }
        return storage.objects(RealmManga.self).filter("title == %@", name).first
    }
    
    @RealmActor
    func addMangaToLibrary(_ manga: RealmManga, update: Bool = false) async -> Bool {
        guard
            let storage = await realmProvider.realm(),
            !(update && storage.object(ofType: RealmManga.self, forPrimaryKey: manga.id) == nil)
        else { return false }
        
        storage.writeAsync {
            storage.add(manga, update: .modified)
        }
        
        return true
    }
    
    @RealmActor
    func observeMangaIds(ids: [String], callback: @escaping (String, Bool) -> Void) async -> NotificationToken? {
        guard let storage = await realmProvider.realm() else { return nil }
        
        let observer = storage.objects(RealmManga.self)
        
        print("Creating new observer... (ID: \(UUID().uuidString)")
        
        return observer.observe { changes in
            switch changes {
            case .initial(let objects):
                print("Initial objects count: \(objects.count)")
                for id in ids {
                    let normalizedId = id.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Check if any manga object matches the current id
                    if let matchingManga = objects.first(where: { manga in
                        let allTitles = [manga.title] + manga.alternativeTitles.map { $0 }
                        let normalizedTitles = allTitles.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
                        return normalizedTitles.contains(normalizedId)
                    }) {
                        // If a matching manga is found, trigger the callback with the matched id
                        print("ID '\(id)' matches with manga: '\(matchingManga.title)'")
                        callback(id, true)
                    } else {
                        // If no match, trigger the callback with false for that id
                        callback(id, false)
                    }
                }
                
            case .update(let objects, let deletions, let insertions, let modifications):
                for manga in objects {
                    let isInLibrary = ids.contains { $0 == manga.normalizedTitles }
                    print("\(manga.title.prefix(10))... is \(isInLibrary ? "in" : "not in") library!")
                    callback(manga.normalizedTitles, isInLibrary)
                }
                
                if !deletions.isEmpty {
                    for index in deletions {
                        let deletedMangaTitle = ids[index]
                        callback(deletedMangaTitle, false)
                    }
                }
                
            case .error(let error):
                print("Error observing manga: \(error)")
            }
        }
    }
    
    @RealmActor
    func observeMangaDbChanges() async -> NotificationToken? {
        guard let storage = await realmProvider.realm() else { return nil }
        
        let observer = storage.objects(RealmManga.self)
        
        return observer.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial(_):
                break
                
            case .update(let objects, let deletions, let insertions, let modifications):
                for manga in objects {
                    if let manga = manga as? RealmManga {
                        print("Manga Title: \(manga.title)")
                    }
                }
                
                print("Deleted at indices: \(deletions)")
                print("Inserted at indices: \(insertions)")
                print("Modified at indices: \(modifications)")
                break
                
            case .error(_):
                break
            }
        }
    }
}
