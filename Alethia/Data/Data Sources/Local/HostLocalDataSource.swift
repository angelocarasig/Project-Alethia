//
//  HostLocalDataSource.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation
import RealmSwift

final class HostLocalDataSource {
    private let realmProvider = RealmProvider()
    
    @RealmActor
    private func findHost(_ host: Host) async -> RealmHost? {
        guard let storage = await realmProvider.realm() else { return nil }
        
        let result = storage.objects(RealmHost.self).filter("name == %@", host.name).first
        
        return result
    }
    
    @RealmActor
    func addHost(_ host: RealmHost, update: Bool = false) async {
        guard
            let storage = await realmProvider.realm(),
            !(update && storage.object(ofType: RealmHost.self, forPrimaryKey: host.name) == nil)
        else { return }
        
        storage.writeAsync {
            storage.add(host, update: .modified)
        }
    }
    
    @RealmActor
    func deleteHost(_ host: Host) async {
        guard 
            let storage = await realmProvider.realm(),
            let hostFromRealm = await findHost(host)
        else { return }
        
        storage.writeAsync {
            storage.delete(hostFromRealm)
        }
    }
    
    @RealmActor
    func getManga(listManga: ListManga) async -> Manga? {
        guard let storage = await realmProvider.realm() else { return nil }
        
        guard listManga.origin == .Local else { return nil }
        
        guard let result = storage.object(ofType: RealmManga.self, forPrimaryKey: listManga.id) else {
            return nil
        }
        
        return result.toDomain()
    }
    
    func getChapterContent(host: Host, source: Source, chapter: Chapter) async throws -> [URL] {
        throw NetworkError.requestFailed
    }
}
