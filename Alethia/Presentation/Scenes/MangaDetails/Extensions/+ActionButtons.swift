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
        removeFromLibrary: @escaping () async -> Void,
        addOrigin: @escaping() async -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Button {
                Haptics.impact()
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
            .animation(.easeInOut(duration: 0.3), value: vm.inLibrary)
            
            // TODO: If ActiveHost is nil, need a prompt to confirm, and if done, pops the stack and goes back to wherever they came from
            Button {
                Task {
                    if (vm.sourcePresent) {
                        Haptics.impact()
                        print("Removed!")
                    }
                    else {
                        Haptics.impact()
                        await addOrigin()
                    }
                }
            } label: {
                Text(Image(systemName: "plus.square.dashed"))
                Text(vm.inLibrary ? "\(manga.origins.count == 1 ? "1 Source" : "\(manga.origins.count) Sources")" : "Add Source")
            }
            .disabled(!vm.inLibrary)
            .fontWeight(.medium)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .foregroundStyle(vm.sourcePresent ? Color("BackgroundColor") : .white)
            .background(vm.sourcePresent ? Color("TextColor") : Color("TintColor"), in: .rect(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.gray.opacity(vm.inLibrary ? 0 : 0.4), lineWidth: 1)
            )
            .opacity(vm.inLibrary ? 1.0 : 0.5)
            .animation(.easeInOut(duration: 0.3), value: vm.sourcePresent)
        }
    }
}
