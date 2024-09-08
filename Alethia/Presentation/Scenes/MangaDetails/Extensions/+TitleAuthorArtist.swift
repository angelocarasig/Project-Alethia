//
//  +TitleAuthorArtist.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import SwiftUI

extension MangaDetailsScreen {
    @ViewBuilder
    func TitleAuthorArtist(title: String, author: String, artist: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .lineLimit(4)
            .multilineTextAlignment(.leading)
        
        Gap(8)
        
        HStack {
            Text(Image(systemName: "pencil"))
            Text(author)
            
            Text(Image(systemName: "paintpalette"))
            Text(artist)
        }
        .frame(alignment: .leading)
    }
}
