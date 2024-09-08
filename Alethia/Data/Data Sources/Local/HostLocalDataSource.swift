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
    func getManga(slug: String) async -> Manga? {
        guard let storage = await realmProvider.realm() else { return nil }
        
        // Search for the RealmOrigin object that matches the given slug
        guard let matchingOrigin = storage.objects(RealmOrigin.self).filter("slug == %@", slug).first else {
            return nil
        }
        
        // Retrieve the associated RealmManga object using the mangaId from the matching origin
        let manga = storage.objects(RealmManga.self).filter("id == %@", matchingOrigin.mangaId).first
        
        return manga?.toDomain()
    }
}
