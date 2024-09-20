//
//  HostSourceCard.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import SwiftUI
import Kingfisher

struct HostSourceCard: View {
    let host: Host
    let source: Source
    
    var body: some View {
        HStack {
            KFImage(URL(fileURLWithPath: source.icon))
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .cornerRadius(4)
                .clipped()
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(source.name)
                    .font(.headline)
                Text(host.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

