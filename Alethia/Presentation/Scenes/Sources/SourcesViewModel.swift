//
//  SourcesViewModel.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import Foundation

@Observable
final class SourcesViewModel {
    private let testHostUseCase: TestHostUseCase
    private let addHostUseCase: AddHostUseCase
    private let removeHostUseCase: RemoveHostUseCase
    
    var addHost: Bool
    var errorMessage: String?
    
    init(
        testHostUseCase: TestHostUseCase,
        addHostUseCase: AddHostUseCase,
        removeHostUseCase: RemoveHostUseCase
    ) {
        self.testHostUseCase = testHostUseCase
        self.addHostUseCase = addHostUseCase
        self.removeHostUseCase = removeHostUseCase
        
        addHost = false
    }
    
    func testNewHost(_ url: String) async -> Host? {
        do {
            return try await testHostUseCase.execute(url)
        } catch {
            self.errorMessage = "Failed to test host: \(error.localizedDescription)"
            return nil
        }
    }
    
    func saveHost(_ host: Host) async {
        do {
            try await addHostUseCase.execute(host)
            self.addHost = false
        } catch {
            self.errorMessage = "Failed to save host: \(error.localizedDescription)"
        }
    }
}

