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
    func getManga(id: String) async -> RealmManga? {
        guard let storage = await realmProvider.realm() else { return nil }
        return storage.object(ofType: RealmManga.self, forPrimaryKey: id)
    }
    
    @RealmActor
    func getManga(name: String) async -> RealmManga? {
        guard let storage = await realmProvider.realm() else { return nil }
        return storage.objects(RealmManga.self).filter("title == %@", name).first
    }
    
    @RealmActor
    func getChapterOrigin(_ chapter: Chapter) async -> Origin? {
        guard let storage = await realmProvider.realm() else { return nil }
        return storage.object(ofType: RealmOrigin.self, forPrimaryKey: chapter.originId)?.toDomain()
    }
    
    @RealmActor
    func getChapterSource(_ origin: Origin) async -> Source? {
        guard let storage = await realmProvider.realm() else { return nil }
        return storage.object(ofType: RealmSource.self, forPrimaryKey: origin.sourceId)?.toDomain()
    }
    
    @RealmActor
    func getChapterHost(_ source: Source) async -> Host? {
        guard let storage = await realmProvider.realm() else { return nil }
        
        let predicate = NSPredicate(format: "ANY sources.id == %@", source.id)
        
        guard let realmHost = storage.objects(RealmHost.self).filter(predicate).first else {
            return nil
        }
        
        return realmHost.toDomain()
    }
    
    @RealmActor
    func getOriginParents(_ origin: Origin) async -> (Host, Source)? {
        guard let storage = await realmProvider.realm() else { return nil }
        
        guard let source = await getChapterSource(origin),
              let host = await getChapterHost(source) else {
            return nil
        }
        
        return (host, source)
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
    func removeMangaFromLibrary(_ manga: Manga) async {
        guard let storage = await realmProvider.realm() else {
            print("Failed to obtain Realm instance.")
            return
        }
        
        do {
            // Fetch the RealmManga object to delete
            if let mangaToDelete = storage.object(ofType: RealmManga.self, forPrimaryKey: manga.id) {
                
                try storage.write {
                    // Step 1: Delete all RealmChapter objects associated with each RealmOrigin
                    for origin in mangaToDelete.origins {
                        let chapters = origin.chapters
                        if !chapters.isEmpty {
                            storage.delete(chapters)
                            print("Deleted \(chapters.count) chapters from origin with slug: \(origin.slug)")
                        }
                    }
                    
                    // Step 2: Delete all RealmOrigin objects associated with the RealmManga
                    if !mangaToDelete.origins.isEmpty {
                        storage.delete(mangaToDelete.origins)
                        print("Deleted \(mangaToDelete.origins.count) origins associated with manga: \(manga.title)")
                    }
                    
                    // Step 3: Delete the RealmManga object itself
                    storage.delete(mangaToDelete)
                    print("Manga '\(manga.title)' successfully removed from library along with its origins and chapters.")
                }
            } else {
                print("Manga with ID \(manga.id) not found in the library.")
            }
        } catch {
            print("Failed to remove manga: \(error.localizedDescription)")
        }
    }
    
    
    @RealmActor
    func addOriginToMangaOrigins(manga: Manga, origin: Origin) async {
        guard let storage = await realmProvider.realm(),
              let manga = await getManga(id: manga.id)
        else { return }
        
        // Not sure if this is even right tbh lol
        storage.writeAsync {
            manga.origins.append(RealmOrigin(origin))
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
                let updatedResults = root.results.enumerated().map { (index, result) -> SourceManga in
                    let title = result.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    let isInLibrary = data.keys.contains(title)
                    
                    // If change happens, add a mapping
                    if root.results[index].inLibrary != isInLibrary && result.slug != data[title]!
                    {
                        print("Title '\(result.title)' already exists in library with ID \(data[title]!)! Creating mapping where \(result.slug) points to \(data[title]!)...")
                        AlternativeHostManager.shared.addAlternativeMapping(
                            original: result.slug,
                            replacement: data[title]!
                        )
                    }
                    
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
                if let activeSource = ActiveHostManager.shared.getActiveSource() {
                    
                    // Return true if the active source is present in the manga's origins.
                    // Default to false if manga.origins is []
                    callback(MangaEvent.sourcePresent(manga?.origins.contains(where: { $0.sourceId == activeSource.id }) ?? false, manga?.toDomain() ))
                } else {
                    // Return true if activeSource is null (meaning this is coming from a different tab)
                    callback(MangaEvent.sourcePresent(true, (manga?.toDomain()) ))
                }
                
                
            case .error(let error):
                print("Error when observing manga: \(error)")
            }
        }
    }
    
    @RealmActor
    func observeLibraryManga(query: MangaQuery?, limit: Int, callback: @escaping ([LibraryManga]) -> Void) async -> NotificationToken? {
        guard let storage = await realmProvider.realm() else { return nil }
        
        /// Available sort options: by title, addedAt, updatedAt, lastReadAt (all by desc/asc)
        /// Available filter options: content rating, content status
        /// search - by title
        
        let search = query?.query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let searchPredicate = search.isEmpty
        ? NSPredicate(value: true) // If search is empty, include all manga
        : NSPredicate(format: "normalizedTitles CONTAINS[c] %@", search) // Else, filter by search
        
        // Create the content rating predicate using a ternary operator
        let ratingPredicate = (query?.filters.rating.isEmpty ?? true)
        ? NSPredicate(value: true) // If rating filters are empty, include all ratings
        : NSPredicate(format: "contentRating IN %@", query!.filters.rating.map { $0.rawValue }) // Else, filter by ratings
        
        // Create the content status predicate using a ternary operator
        let statusPredicate = (query?.filters.status.isEmpty ?? true)
        ? NSPredicate(value: true) // If status filters are empty, include all statuses
        : NSPredicate(format: "contentStatus IN %@", query!.filters.status.map { $0.rawValue }) // Else, filter by statuses
        
        let observer = storage.objects(RealmManga.self)
            .filter(searchPredicate)
            .filter(ratingPredicate)
            .filter(statusPredicate)
            .sorted(byKeyPath: query?.sort.sort.keyPath ?? "addedAt", ascending: query?.sort.direction.isAscending ?? true)
        
        return observer.observe { changes in
            switch changes {
            case let .initial(objects), let .update(objects, _, _, _):
                let manga = limit > 0 ? Array(objects.prefix(limit)) : Array(objects)
                callback(manga.map{ $0.toLibraryManga() } )
                
            case .error(let error):
                print("Error while observing library manga: \(error.localizedDescription)")
            }
        }
    }
}
