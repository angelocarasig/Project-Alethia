//
//  +Additional.swift
//  Alethia
//
//  Created by Angelo Carasig on 20/9/2024.
//

import SwiftUI

extension MangaDetailsScreen {
    @ViewBuilder
    func Additional(_ manga: Manga) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Content Rating")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(manga.contentRating.rawValue)
                .font(.system(size: 16))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .foregroundColor(Color("TextColor"))
                .background(Color("TintColor"))
                .cornerRadius(8)
        }
        
        Gap(20)
        
        VStack(alignment: .leading, spacing: 4) {
            Text("Content Status")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(manga.contentStatus.rawValue)
                .font(.system(size: 16))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .foregroundColor(Color("TextColor"))
                .background(Color("TintColor"))
                .cornerRadius(8)
        }
    }
}
