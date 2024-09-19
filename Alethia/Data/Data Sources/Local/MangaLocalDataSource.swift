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
    func addMangaToLibrary(_ manga: RealmManga, update: Bool = false) async -> Void {
        guard
            let storage = await realmProvider.realm(),
            !(update && storage.object(ofType: RealmManga.self, forPrimaryKey: manga.id) == nil)
        else { return }
        
        storage.writeAsync {
            storage.add(manga, update: .modified)
        }
    }
    
    @RealmActor
    func removeMangaFromLibrary(_ manga: Manga) async -> Void {
        guard let storage = await realmProvider.realm() else { return }
        
        do {
            if let mangaToDelete = storage.object(ofType: RealmManga.self, forPrimaryKey: manga.id) {
                try storage.write {
                    storage.delete(mangaToDelete)
                    print("Manga successfully removed from library.")
                }
            } else {
                print("Manga not found in the library.")
            }
        } catch {
            print("Failed to remove manga: \(error.localizedDescription)")
        }
    }
    
    @RealmActor
    func observeSourceManga(roots: [SourceResult], paths: [SourceManga], callback: @escaping ([SourceResult], [SourceManga]) -> Void) async -> NotificationToken? {
        guard let storage = await realmProvider.realm() else { return nil }
        let observer = storage.objects(RealmManga.self)
        
        let handler: (Results<RealmManga>) -> Void = { objects in
            /// 1. Iterate through each source result
            /// 2. Iterate through each source manga
            /// 3. Find source manga in db
            /// 4. Set isInLibrary value for if its in library or not
            /// 5. If it's in library, retrieve that manga's ID and set the ID to that value, and set its origin to .Local, otherwise .Remote so that it can be retrieved from local instead
            /// 6. Trigger callback with new [SourceResult] and [SourceManga] arrays
            
            // Dictionary where dict[mangaNormalizedTitle] = mangaId
            let data: [String: String] = Dictionary(uniqueKeysWithValues: objects.flatMap { manga in
                manga.normalizedTitles
                    .split(separator: "|")
                    .map { normalizedTitle in
                        (normalizedTitle.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), manga.id)
                    }
            })
            
            let outputRoots: [SourceResult] = roots.map { root -> SourceResult in
                let updatedResults = root.results.map { result -> SourceManga in
                    let title = result.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    let isInLibrary = data.keys.contains(title)
                    
                    return SourceManga(
                        id: isInLibrary ? data[title]! : result.slug,
                        slug: result.slug,
                        title: result.title,
                        coverUrl: result.coverUrl,
                        origin: isInLibrary ? .Local : .Remote,
                        inLibrary: isInLibrary
                    )
                }
                
                return SourceResult(
                    index: root.index,
                    name: root.name,
                    path: root.path,
                    results: updatedResults
                )
            }
            
            let outputPaths: [SourceManga] = paths.map { path -> SourceManga in
                let title = path.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                let isInLibrary = data.keys.contains(title)
                
                return SourceManga(
                    id: isInLibrary ? data[title]! : path.slug,
                    slug: path.slug,
                    title: path.title,
                    coverUrl: path.coverUrl,
                    origin: isInLibrary ? .Local : .Remote,
                    inLibrary: isInLibrary
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
                
                // print("Manga Title is: \(String(describing: manga?.title))")
                
                /// Cases
                /// 1. Manga added/removed from library event
                /// 2. Source added/removed from library event
                /// ...
                
                // # 1
                // print("Current manga is \(manga != nil ? "in" : "not in") library!")
                callback(MangaEvent.inLibrary(manga != nil))
                
                // # 2 - If the origins is not empty or if manga doesn't exist, source is not present (false)
                // print("Current manga has \(manga?.origins.isEmpty ?? false ? "non-empty (\(manga!.origins.count))" : "empty") source list!")
                callback(MangaEvent.sourcePresent( manga?.origins.isEmpty ?? false ))
                
            case .error(let error):
                print("Error when observing manga: \(error)")
            }
        }
    }
    
    @RealmActor
    func observeLibraryManga(callback: @escaping ([Manga]) -> Void) async -> NotificationToken? {
        guard let storage = await realmProvider.realm() else { return nil }
        
        let observer = storage.objects(RealmManga.self)
        
        return observer.observe { changes in
            switch changes {
            case let .initial(objects):
                let manga = Array(objects.map { $0.toDomain() })
                
                // print("Initial Triggered!")
                // print("Manga Count: \(manga.count)")
                
                callback(manga)
                
            case let .update(objects, _, _, _):
                let manga = Array(objects.map { $0.toDomain() })
                
                // print("Update Triggered!")
                // print("Manga Count: \(manga.count)")
                
                callback(manga)
                
            case .error(let error):
                print("Error while observing library manga: \(error.localizedDescription)")
            }
        }
    }
}
