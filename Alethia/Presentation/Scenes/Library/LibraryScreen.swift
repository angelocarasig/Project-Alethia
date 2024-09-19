//
//  LibraryScreen.swift
//  Alethia
//
//  Created by Angelo Carasig on 20/9/2024.
//

import SwiftUI

struct LibraryScreen: View {
    var body: some View {
        NavigationStack {
            ContentView()
                .navigationTitle("Library")
        }
    }
}

private extension LibraryScreen {
    @ViewBuilder
    func ContentView() -> some View {
        Text("Hi")
    }
}

#Preview {
    LibraryScreen()
}
