//
//  HostSourceCard.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import SwiftUI

struct HostSourceCard: View {
    let host: Host
    let source: Source
    
    var body: some View {
        HStack {
            Image(systemName: "square.stack.3d.down.dottedline")
                .resizable()
                .frame(width: 20, height: 20)
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

#Preview {
    let source1 = Source(
        id: UUID().uuidString,
        name: "Some enabled source",
        path: "/source1",
        routes: [],
        enabled: true
    )
    
    let host = Host(name: "Some Host", sources: [source1], baseUrl: "Some URL")
    
    return HostSourceCard(host: host, source: source1)
}
