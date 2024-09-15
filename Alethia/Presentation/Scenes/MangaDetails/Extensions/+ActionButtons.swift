//
//  +ActionButtons.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import SwiftUI
import RealmSwift
import LucideIcons

extension MangaDetailsScreen {
    @ViewBuilder
    func ActionButtons(
        manga: Manga,
        addToLibrary: @escaping () async -> Void,
        removeFromLibrary: @escaping () async -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Button {
                Task {
                    if (vm.inLibrary) {
                        await removeFromLibrary()
                    }
                    else {
                        await addToLibrary()
                    }
                }
            } label: {
                Text(Image(systemName: "heart"))
                Text(vm.inLibrary ? "In Library" : "Add to Library")
            }
            .fontWeight(.medium)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .foregroundStyle(vm.inLibrary ? Color("BackgroundColor") : .white)
            .background(vm.inLibrary ? Color("TextColor") : Color("TintColor"), in: .rect(cornerRadius: 12, style: .continuous))
            
            Button {
                Task {
                    if (vm.inLibrary) {
                        await removeFromLibrary()
                    }
                    else {
                        await addToLibrary()
                    }
                }
            } label: {
                Text(Image(systemName: "plus.square.dashed"))
                Text(vm.inLibrary ? "Source Registered" : "Add Source")
            }
            .fontWeight(.medium)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .foregroundStyle(vm.inLibrary ? Color("BackgroundColor") : .white)
            .background(vm.inLibrary ? Color("TextColor") : Color("TintColor"), in: .rect(cornerRadius: 12, style: .continuous))
        }
    }
}
