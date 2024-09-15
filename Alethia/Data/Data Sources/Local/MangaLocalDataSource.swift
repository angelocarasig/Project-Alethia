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
    func observeSourceManga(roots: [SourceResult], paths: [SourceManga], callback: @escaping ([SourceResult], [SourceManga]) -> Void) async -> NotificationToken? {
        guard let storage = await realmProvider.realm() else { return nil }
        let observer = storage.objects(RealmManga.self)
        
        let handler: (Results<RealmManga>) -> Void = { objects in
            /// 1. Iterate through each source result
            /// 2. Iterate through each source manga
            /// 3. Find source manga in db
            /// 4. Append to new array if exists or not
            /// 5. Trigger callback with new [SourceResult] and [SourceManga] arrays
            
            // Set > Dictionary in this case. Calculate once only here to be used in output roots/paths
            let set: Set<String> = Set(objects.flatMap { manga in
                manga.normalizedTitles
                    .split(separator: "|")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            })
            
            let outputRoots: [SourceResult] = roots.map { root -> SourceResult in
                let updatedResults = root.results.map { result -> SourceManga in
                    let isInLibrary = set.contains(result.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
                    
                    let updatedResult = result
                    updatedResult.inLibrary = isInLibrary
                    return updatedResult
                }
                
                return SourceResult(
                    index: root.index,
                    name: root.name,
                    path: root.path,
                    results: updatedResults
                )
            }
            
            let outputPaths: [SourceManga] = paths.map { path -> SourceManga in
                return SourceManga(
                    id: path.id,
                    title: path.title,
                    coverUrl: path.coverUrl,
                    origin: path.origin,
                    inLibrary: set.contains(path.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
                )
            }
            
            callback(outputRoots, outputPaths)
        }
        
        return observer.observe { changes in
            switch changes {
            case let .initial(objects):
                handler(objects)
                
            case .update(let objects, _, _, _):
                handler(objects)
                
            case .error:
                print("Error")
            }
        }
    }
    
    @RealmActor
    func observeManga(manga: Manga, callback: @escaping (MangaEvent) -> Void) async -> NotificationToken? {
        guard let storage = await realmProvider.realm() else { return nil }
        
        /// TODO: Stricter Querying
        /// CASE 1 - "Fate" not in library but "Fate Grand Order" in library - Don't create false positive
        /// CASE 2 - Identical titles "Fate" and "Fate" but different manga. - need some form of unique differentiation/identification
        ///
        
        let query = "|" + manga.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) + "|"
        let observer = storage.objects(RealmManga.self).where { $0.normalizedTitles.contains(query) }
        
        return observer.observe { changes in
            switch changes {
            case .initial(let objects), .update(let objects, _, _, _):
                guard objects.count <= 1 else {
                    callback(.errorOccurred("Multiple manga found with the same title"))
                    return
                }
                
                let manga = objects.first
                
                print("Manga Title is: \(String(describing: manga?.title))")
                
                /// Cases
                /// 1. Manga added/removed from library event
                /// 2. Source added/removed from library event
                /// ...
                
                // # 1
                callback(MangaEvent.inLibrary(manga != nil))
                
                // # 2 - If the origins is not empty or if manga doesn't exist, source is not present (false)
                callback(MangaEvent.sourcePresent( manga?.origins.isEmpty ?? false ))
                
            case .error(let error):
                print("Error when observing manga: \(error)")
            }
        }
    }
    
}
