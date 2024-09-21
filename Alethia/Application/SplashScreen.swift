//
//  SplashScreen.swift
//  Alethia
//
//  Created by Angelo Carasig on 21/9/2024.
//

import SwiftUI

struct SplashScreen: View {
    @Binding var isActive: Bool
    
    var body: some View {
        VStack {
            Image("SplashImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("SplashBackground"))
        .ignoresSafeArea()
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

