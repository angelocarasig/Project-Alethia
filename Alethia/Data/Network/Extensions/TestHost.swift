import SwiftUI
import Kingfisher

private func downloadImage(name: String, url: URL) async -> String? {
    await withCheckedContinuation { continuation in
        let downloader = ImageDownloader.default
        
        downloader.downloadImage(with: url, options: nil) { result in
            switch result {
            case .success(let value):
                let image = value.image
                
                if let imageData = image.pngData() {
                    let fileManager = FileManager.default
                    let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileName = name + ".png"
                    let fileURL = documentDirectory.appendingPathComponent(fileName)
                    
                    do {
                        try imageData.write(to: fileURL)
                        continuation.resume(returning: fileURL.path)
                    } catch {
                        print("Error saving image to file: \(error)")
                        continuation.resume(returning: nil)
                    }
                } else {
                    print("Failed to convert image to PNG data.")
                    continuation.resume(returning: nil)
                }
                
            case .failure(let error):
                print("Image download failed: \(error)")
                continuation.resume(returning: nil)
            }
        }
    }
}

extension NetworkService: TestHostProtocol {
    func testHost(url: String) async throws -> Host {
        
        // Check Base Path
        guard let hostURL = URL.appendingPaths(url) else {
            throw NetworkError.missingURL
        }
        
        let hostDTO: HostDTO = try await request(url: hostURL)
        
        // Base Path/{Source}
        var sources: [Source] = []
        
        for sourceDTO in hostDTO.sources {
            let sourceURL = URL.appendingPaths(hostURL.absoluteString, sourceDTO.path)
            let routesDTO: SourceRoutesDTO = try await request(url: sourceURL!)
            
            if let iconPath = await downloadImage(name: sourceDTO.source, url: URL.appendingPaths(sourceURL!.absoluteString, "icon")!) {
                print("Icon Path! ", iconPath)
                
                // Base Path/Source/{Route}
                let routes = routesDTO.routes.map { SourceRoute(name: $0.name, path: $0.path) }
                let sourceItem = Source(
                    id: UUID().uuidString,
                    name: sourceDTO.source,
                    icon: iconPath,
                    referer: routesDTO.referer,
                    path: sourceDTO.path,
                    routes: routes,
                    enabled: true
                )
                
                sources.append(sourceItem)
            }
        }
        
        print("Sources: ", sources)
        
        return Host(name: hostDTO.repository, sources: sources, baseUrl: hostURL.absoluteString)
    }
}
