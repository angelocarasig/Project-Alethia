//
//  UseCaseFactory.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import Foundation

final class UseCaseFactory {
    static let shared = UseCaseFactory()
    
    private init() {}
    
    private lazy var networkService = NetworkService()
    
    private lazy var mangaRepository: MangaRepository = {
        let local = MangaLocalDataSource()
        let remote = MangaRemoteDataSource(networkService: networkService)
        
        return MangaRepositoryImplementation(local: local, remote: remote)
    }()
    
    private lazy var hostRepository: HostRepository = {
        let local = HostLocalDataSource()
        let remote = HostRemoteDataSource(networkService: networkService)
        
        return HostRepositoryImplementation(local: local, remote: remote)
    }()
}

// MARK - Host Repository

extension UseCaseFactory {
    func makeAddHostUseCase() -> AddHostUseCase {
        return AddHostUseCaseImpl(host: hostRepository)
    }
    
    func makeRemoveHostUseCase() -> RemoveHostUseCase {
        return RemoveHostUseCaseImpl(host: hostRepository)
    }
    
    func makeTestHostUseCase() -> TestHostUseCase {
        return TestHostUseCaseImpl(repo: hostRepository)
    }
    
    func makeFetchHostSourceContentUseCase() -> FetchHostSourceContentUseCase {
        return FetchHostSourceContentImpl(repo: hostRepository)
    }
    
    func makeFetchHostSourceMangaUseCase() -> FetchHostSourceMangaUseCase {
        return FetchHostSourceMangaImpl(repo: hostRepository)
    }
}

// MARK - Manga Repository

extension UseCaseFactory {
    func makeObserveSourceMangaUseCase() -> ObserveSourceMangaUseCase {
        return ObserveSourceMangaImpl(repo: mangaRepository)
    }
    
    func makeObserveMangaUseCase() -> ObserveMangaUseCase {
        return ObserveMangaImpl(repo: mangaRepository)
    }
    
    func makeAddMangaToLibraryUseCase() -> AddMangaToLibraryUseCase {
        return AddMangaToLibaryImpl(repo: mangaRepository)
    }
}
