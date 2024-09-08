//
//  NetworkService+AddRepository.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation

extension NetworkService: TestHostProtocol {
    func testHost(url: String) async throws -> Host {
        
        // Check Base Path
        guard let hostURL = URL.appendingPaths(url) else {
            throw NetworkError.missingURL
        }
        
        let hostDTO: HostDTO = try await request(url: hostURL)
        
        // Base Path/{Source}
        var sources: Array<Source> = []
        
        for sourceDTO in hostDTO.sources {
            let sourceURL = URL.appendingPaths(hostURL.absoluteString, sourceDTO.path)
            let routesDTO: SourceRoutesDTO = try await request(url: sourceURL!)
            
            // Base Path/Source/{Route}
            let routes = routesDTO.routes.map { SourceRoute(name: $0.name, path: $0.path) }
            let sourceItem = Source(id: UUID().uuidString, name: sourceDTO.source, path: sourceDTO.path, routes: routes, enabled: true)
            
            sources.append(sourceItem)
        }
        
        return Host(name: hostDTO.repository, sources: sources, baseUrl: hostURL.absoluteString)
    }
}
