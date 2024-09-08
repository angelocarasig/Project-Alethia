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
            Text("Library")
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("Library")
                }
            
            Text("Search")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
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
            
            Text("Settings")
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    RootView()
}
