//
//  +SortModal.swift
//  Alethia
//
//  Created by Angelo Carasig on 23/9/2024.
//

import SwiftUI
import LucideIcons

extension LibraryScreen {
    @ViewBuilder
    func SortModal() -> some View {
        VStack(spacing: 10) {
            Text("Sort Options")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Gap(10)
            
            ForEach(SortOption.allCases, id: \.self) { option in
                Entry(
                    text: option.rawValue,
                    enabled: selectedSortOption == option,
                    sortDirection: $selectedSortDirection,
                    onSelect: {
                        selectedSortOption = option
                    }
                )
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Text("Set as Default")
                    .font(.subheadline)
                    .foregroundColor(AppColors.text)
                    .padding(8)
                    .background(Color.blue.opacity(0.25))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
            .padding(.trailing, 16)
        }
        .padding()
        .presentationDetents([.fraction(0.5), .fraction(0.75)])
    }
}
private struct Entry: View {
    let text: String
    let enabled: Bool
    let sortDirection: Binding<SortDirection>
    let onSelect: () -> Void
    
    @State private var isFlipping = false // just for state
    
    var body: some View {
        HStack {
            Text(text)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
            
            Spacer()
            
            if enabled {
                Image(systemName: sortDirection.wrappedValue == .ascending
                      ? "chevron.up"
                      : "chevron.down"
                )
                .foregroundColor(AppColors.text)
                .padding(.top, 4)
                .padding(.leading, 4)
                .animation(.easeInOut(duration: 0.2), value: isFlipping)
            }
        }
        .frame(alignment: .center)
        .padding(12)
        .background(enabled ? Color.gray.opacity(0.3) : Color.clear)
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                if enabled {
                    flipSortDirection()
                } else {
                    onSelect()
                }
            }
        }
    }
    
    private func flipSortDirection() {
        isFlipping.toggle()
        sortDirection.wrappedValue = sortDirection.wrappedValue == .ascending ? .descending : .ascending
    }
}
