//
//  +Skeleton.swift
//  Alethia
//
//  Created by Angelo Carasig on 10/9/2024.
//

import SwiftUI

extension MangaDetailsScreen {
    @ViewBuilder
    func SkeletonView() -> some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    Spacer().frame(height: geometry.size.height / 3)
                    
                    // Skeleton for Title, Author, Artist
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 30)
                        .cornerRadius(6)
                    
                    Gap(12)
                    
                    // Action Buttons
                    HStack {
                        ForEach(0..<2) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 44)
                                .cornerRadius(6)
                        }
                    }
                    
                    Gap(12)
                    
                    // Description
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 100)
                        .cornerRadius(6)
                    
                    Gap(22)
                    
                    // Tags
                    HStack {
                        ForEach(0..<4) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 30)
                                .cornerRadius(6)
                        }
                    }
                    
                    Gap(22)
                    
                    // Tabs
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 50)
                        .cornerRadius(6)
                }
                .padding(.leading, 12)
                .padding(.trailing, 16)
                .background(
                    VStack(spacing: 0) {
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color("BackgroundColor").opacity(0.0), location: 0.0),
                                .init(color: Color("BackgroundColor").opacity(1.0), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .center
                        )
                        .frame(height: 700)
                        
                        Color("BackgroundColor")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                        .frame(width: geometry.size.width)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
