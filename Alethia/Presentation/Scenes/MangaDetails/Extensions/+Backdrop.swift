//
//  +Backdrop.swift
//  Alethia
//
//  Created by Angelo Carasig on 7/9/2024.
//

import SwiftUI
import Kingfisher

extension MangaDetailsScreen {
    // For a fade in animation, we need to remove animation from KFImage but can only be done this way
    @available(iOS, deprecated: 15.0)
    @ViewBuilder
    func Backdrop(coverUrl: URL) -> some View {
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
                        .scaledToFill()
                        .frame(height: 600)
                        .frame(width: geometry.size.width)
                        .clipped()
                        .animation(.none)
                    
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
        .ignoresSafeArea(.container, edges: .top)
    }
}

