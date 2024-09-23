//
//  +FilterModal.swift
//  Alethia
//
//  Created by Angelo Carasig on 23/9/2024.
//

import SwiftUI
import LucideIcons

extension LibraryScreen {
    @ViewBuilder
    func FilterModal() -> some View {
        VStack(spacing: 16) {
            Text("Filter Options")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Gap(10)
            
            VStack(alignment: .leading, spacing: 24) {
                // Content Status Filter
                Text("Content Status")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                HStack {
                    ForEach(ContentStatus.allCases, id: \.self) { status in
                        MultiSelectChip(text: status.rawValue, isSelected: $selectedContentStatus, filterType: status)
                    }
                }
                .padding(.horizontal, 16)
                
                // Content Rating Filter
                Text("Content Rating")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                HStack {
                    ForEach(ContentRating.allCases, id: \.self) { rating in
                        MultiSelectChip(text: rating.rawValue, isSelected: $selectedContentRating, filterType: rating)
                    }
                }
                .padding(.horizontal, 16)
                
                // Date Filters
                Text("Date Filters")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                VStack(spacing: 8) {
                    DatePicker("Last Read At", selection: $lastReadAt, displayedComponents: .date)
                        .padding(.horizontal, 16)
                    
                    DatePicker("Added At", selection: $addedAt, displayedComponents: .date)
                        .padding(.horizontal, 16)
                    
                    DatePicker("Updated At", selection: $updatedAt, displayedComponents: .date)
                        .padding(.horizontal, 16)
                }
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Text("Apply Filters")
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
        .presentationDetents([.fraction(0.75), .fraction(0.85)])
    }
}

// MultiSelectChip View for multi-select filter options
private struct MultiSelectChip<T: Hashable>: View {
    let text: String
    @Binding var isSelected: Set<T>
    let filterType: T
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected.contains(filterType) ? Color.blue.opacity(0.25) : Color.clear)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected.contains(filterType) ? Color.blue : Color.gray, lineWidth: 1)
            )
            .onTapGesture {
                Haptics.impact()
                withAnimation(.easeInOut(duration: 0.2)) {
                    toggleSelection()
                }
            }
    }
    
    private func toggleSelection() {
        if isSelected.contains(filterType) {
            isSelected.remove(filterType)
        } else {
            isSelected.insert(filterType)
        }
    }
}
