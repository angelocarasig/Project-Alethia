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
    
    private lazy var chapterRepository: ChapterRepository = {
        let local = ChapterLocalDataSource()
        let remote = ChapterRemoteDataSource()
        
        return ChapterRepositoryImplementation(local: local, remote: remote)
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
    
    func makeFetchNewOriginDataUseCase() -> FetchNewOriginDataUseCase {
        return FetchNewOriginDataImpl(repo: hostRepository)
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
    
    func makeObserveLibraryMangaUseCase() -> ObserveLibraryMangaUseCase {
        return ObserveLibraryMangaImpl(repo: mangaRepository)
    }
    
    func makeGetOriginParentsUseCase() -> GetOriginParentsUseCase {
        return GetOriginParentsImpl(repo: mangaRepository)
    }
    
    func makeAddMangaToLibraryUseCase() -> AddMangaToLibraryUseCase {
        return AddMangaToLibaryImpl(repo: mangaRepository)
    }
    
    func makeRemoveMangaFromLibraryUseCase() -> RemoveMangaFromLibraryUseCase {
        return RemoveMangaFromLibraryImpl(repo: mangaRepository)
    }
    
    func makeAddOriginToMangaOriginsUseCase() -> AddOriginToMangaOriginsUseCase {
        return AddOriginToMangaOriginsImpl(repo: mangaRepository)
    }
    
    func makeFetchChapterContentUseCase() -> FetchChapterContentUseCase {
        return FetchChapterContentImpl(repo: mangaRepository)
    }
}

// MARK - Chapter Repository

extension UseCaseFactory {
    func makeGetChapterRefererUseCase() -> GetChapterRefererUseCase {
        return GetChapterRefererImpl(repo: chapterRepository)
    }
    
    func makeGetNextChapterUseCase() -> GetNextChapterUseCase {
        return GetNextChapterImpl(repo: chapterRepository)
    }
    
    func makeGetPreviousChapterUseCase() -> GetPreviousChapterUseCase {
        return GetPreviousChapterImpl(repo: chapterRepository)
    }
}
