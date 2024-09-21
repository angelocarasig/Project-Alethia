//
//  AlethiaApp.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import SwiftUI

@main
struct AlethiaApp: App {
    @State private var showSplashScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                
                if showSplashScreen {
                    SplashScreen(isActive: $showSplashScreen)
                        .zIndex(100)
                }
            }
            .onAppear {
                runBackgroundProcesses()
            }
        }
    }
    
    private func runBackgroundProcesses() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showSplashScreen = false
            }
        }
    }
}
