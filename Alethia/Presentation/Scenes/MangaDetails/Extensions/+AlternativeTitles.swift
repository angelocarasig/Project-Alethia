//
//  +AlternativeTitles.swift
//  Alethia
//
//  Created by Angelo Carasig on 21/9/2024.
//

import SwiftUI

extension MangaDetailsScreen {
    @ViewBuilder
    func AlternativeTitles(titles: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Alternative Titles")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Gap(8)
            
            ForEach(titles, id: \.self) { title in
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.text.opacity(0.75))
                
                Gap(2)
            }
        }
    }
}
