//
//  MangaCard.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import SwiftUI
import Kingfisher
import LucideIcons

struct MangaCard<Destination: View>: View {
    let item: ListManga
    let destination: Destination
    var isInLibrary: Bool = false
    
    @State private var isImageLoading: Bool = true
    
    var body: some View {
        let dimensions = DimensionsCache.shared.dimensions
        
        NavigationLink(destination: destination) {
            VStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    if isImageLoading {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: dimensions.width, height: dimensions.height)
                            .cornerRadius(8)
                    }
                    
                    KFImage(URL(string: item.coverUrl))
                        .resizable()
                        .fade(duration: 0.25)
                        .onSuccess { _ in
                            isImageLoading = false
                        }
                        .onFailure { _ in
                            isImageLoading = false
                        }
                        .scaledToFill()
                        .aspectRatio(11/16, contentMode: .fit)
                        .frame(width: dimensions.width, height: dimensions.height)
                        .cornerRadius(8)
                        .clipped()
                        .overlay(
                            isInLibrary ? Color.black.opacity(0.5) : Color.clear // Overlay for items in the library
                        )
                    
                    if isInLibrary {
                        Image(uiImage: Lucide.badgeCheck)
                            .lucide(color: .green)
                            .padding(.top, 4)
                            .padding(.leading, 4)
                    }
                }
                
                Text(item.title)
                    .font(.caption)
                    .lineLimit(2)
                    .frame(width: dimensions.width, height: 40, alignment: .topLeading)
                    .truncationMode(.tail)
            }
            .padding(.bottom, 5)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            Haptics.impact()
        }
    }
}

#Preview {
    let sampleManga = ListManga(id: "1", title: "Sample Manga", coverUrl: "https://example.com/image.jpg", origin: ListManga.Origin.Remote)
    
    return MangaCard(item: sampleManga, destination: Text("Manga Details"))
}
