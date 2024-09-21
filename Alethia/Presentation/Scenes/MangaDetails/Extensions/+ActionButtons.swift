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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(vm.inLibrary ? AppColors.background : .white)
            .background(vm.inLibrary ? AppColors.text : AppColors.tint, in: .rect(cornerRadius: 12, style: .continuous))
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(vm.sourcePresent ? AppColors.background : .white)
            .background(vm.sourcePresent ? AppColors.text : AppColors.tint, in: .rect(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.gray.opacity(vm.inLibrary ? 0 : 0.4), lineWidth: 1)
            )
            .opacity(vm.inLibrary ? 1.0 : 0.5)
            .animation(.easeInOut(duration: 0.3), value: vm.sourcePresent)
            
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
                Image(uiImage: vm.inLibrary ? Lucide.mapPinCheckInside : Lucide.mapPinOff)
                    .lucide(color: vm.inLibrary ? AppColors.background : AppColors.text)
            }
            .disabled(!vm.inLibrary)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(vm.sourcePresent ? AppColors.text : AppColors.tint, in: .rect(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.gray.opacity(vm.inLibrary ? 0 : 0.4), lineWidth: 1)
            )
            .opacity(vm.inLibrary ? 1.0 : 0.5)
            .animation(.easeInOut(duration: 0.3), value: vm.sourcePresent)
        }
        .frame(height: 45)
    }
}
