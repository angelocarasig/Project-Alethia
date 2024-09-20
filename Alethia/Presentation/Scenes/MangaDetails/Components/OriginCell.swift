//
//  OriginCell.swift
//  Alethia
//
//  Created by Angelo Carasig on 20/9/2024.
//

import SwiftUI
import Kingfisher
import LucideIcons

struct OriginCell: View {
    let data: OriginCellData
    let sourcePresent: Bool
    
    var body: some View {
        print("Current Origin BG: ", data.origin.coverUrl)
        
        return ZStack {
            KFImage(URL(string: data.origin.coverUrl))
                .resizable()
                .scaledToFill()
                .blur(radius: 16)
                .overlay(Color("BackgroundColor").opacity(0.3))
                .cornerRadius(15)
                .clipped()
                .frame(height: 100)
            
            HStack {
                KFImage(URL(fileURLWithPath: data.source.icon))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(4)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(data.source.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TextColor"))
                        .lineLimit(1)
                    
                    Text(data.host.name)
                        .font(.subheadline)
                        .foregroundColor(Color("TextColor").opacity(0.75))
                        .lineLimit(1)
                    
                    Text("\(data.origin.chapters.count) Chapters")
                        .font(.subheadline)
                        .foregroundColor(Color("TextColor"))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.leading, 10)
                
                Spacer()
                
                VStack {
                    Image(uiImage: Lucide.ellipsisVertical)
                        .lucide(color: Color("TextColor"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color("TextColor"))
                }
                .padding(.trailing, 10)
            }
            .padding()
        }
        .background(Color.clear)
        .cornerRadius(15)
        .shadow(radius: 2)
        .grayscale(sourcePresent ? 0 : 1)
    }
}
