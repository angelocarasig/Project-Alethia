//
//  RootView.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import SwiftUI

struct RootView: View {
    private let appFactory = UseCaseFactory.shared
    
    var body: some View {
        TabView {
            HomeScreen(vm: ViewModelFactory.shared.makeHomeViewModel())
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .onAppear {
                    ActiveHostManager.shared.clearActiveHost()
                }
            
            LibraryScreen()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("Library")
                }
                .onAppear {
                    ActiveHostManager.shared.clearActiveHost()
                }
            
            Text("Search")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .onAppear {
                    ActiveHostManager.shared.clearActiveHost()
                }
            
            SourcesScreen(vm: SourcesViewModel(
                testHostUseCase: appFactory.makeTestHostUseCase(),
                addHostUseCase: appFactory.makeAddHostUseCase(),
                removeHostUseCase: appFactory.makeRemoveHostUseCase()
            ))
            .tabItem {
                Image(systemName: "plus.square.dashed")
                Text("Sources")
            }
            
            Text("History")
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
                .onAppear {
                    ActiveHostManager.shared.clearActiveHost()
                }
        }
    }
}

#Preview {
    RootView()
}
