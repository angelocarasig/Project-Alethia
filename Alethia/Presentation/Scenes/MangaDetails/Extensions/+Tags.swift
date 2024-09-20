//
//  +Tags.swift
//  Alethia
//
//  Created by Angelo Carasig on 7/9/2024.
//

import SwiftUI
import Flow

extension MangaDetailsScreen {
    @ViewBuilder
    func Tags(tags: [String]) -> some View {
        HFlow {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: 14))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .foregroundColor(Color("TextColor"))
                    .background(Color("TintColor"))
                    .cornerRadius(8)
            }
        }
    }
}
