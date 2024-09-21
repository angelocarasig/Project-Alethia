//
//  +Additional.swift
//  Alethia
//
//  Created by Angelo Carasig on 20/9/2024.
//

import SwiftUI

private extension ContentRating {
    var backgroundColor: Color {
        switch self {
        case .unknown:
            return Color.gray
        case .safe:
            return AppColors.green
        case .suggestive:
            return AppColors.yellow
        case .explicit:
            return AppColors.red
        }
    }
}

private extension ContentStatus {
    var backgroundColor: Color {
        switch self {
        case .ongoing:
            return AppColors.blue
        case .hiatus:
            return AppColors.orange
        case .cancelled:
            return AppColors.red
        case .completed:
            return AppColors.green
        }
    }
}


extension MangaDetailsScreen {
    @ViewBuilder
    func Additional(_ manga: Manga) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Content Rating")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(manga.contentRating.rawValue)
                    .font(.system(size: 16))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .foregroundColor(AppColors.text)
                    .background(manga.contentRating.backgroundColor)
                    .cornerRadius(8)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Content Status")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(manga.contentStatus.rawValue)
                    .font(.system(size: 16))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .foregroundColor(AppColors.text)
                    .background(manga.contentStatus.backgroundColor)
                    .cornerRadius(8)
            }
        }
    }
}
