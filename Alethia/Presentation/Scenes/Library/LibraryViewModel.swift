//
//  LibraryViewModel.swift
//  Alethia
//
//  Created by Angelo Carasig on 23/9/2024.
//

import Foundation
import RealmSwift

@Observable
final class LibraryViewModel {
    var manga: [Manga] = []
    var contentLoaded: Bool = false
    
    private var observer: NotificationToken?
    
    private var observeLibraryMangaUseCase: ObserveLibraryMangaUseCase
    
    init(
        observeLibraryMangaUseCase: ObserveLibraryMangaUseCase
    ) {
        self.observeLibraryMangaUseCase = observeLibraryMangaUseCase
    }
    
    func onOpen() async {
        // If content already loaded just return
        guard !contentLoaded else { return }
        
        observer = await observeLibraryMangaUseCase.execute { manga in
            self.manga = manga
            self.contentLoaded = true
        }
    }
}
