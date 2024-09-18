//
//  +Backdrop.swift
//  Alethia
//
//  Created by Angelo Carasig on 7/9/2024.
//

import SwiftUI
import Kingfisher

extension MangaDetailsScreen {
    @ViewBuilder
    func Backdrop(coverUrl: URL) -> some View {
        VStack {
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        KFImage(coverUrl)
                            .placeholder {
                                ProgressView()
                                    .frame(height: 600)
                            }
                            .retry(maxCount: 5, interval: .seconds(2))
                            .resizable()
                            .fade(duration: 0.25)
                            .scaledToFill()
                            .frame(height: 600)
                            .frame(width: geometry.size.width)
                            .clipped()
                        
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color("BackgroundColor").opacity(0.0), location: 0.0),
                                .init(color: Color("BackgroundColor").opacity(1.0), location: 1.0)
                            ]),
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 600)
                    }
                    
                    Spacer()
                }
            }
            Spacer()
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}

