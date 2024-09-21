//
//  ExpandableList.swift
//  Alethia
//
//  Created by Angelo Carasig on 20/9/2024.
//

import SwiftUI

struct ExpandableList<Content: View>: View {
    let name: String
    @Binding var isExpanded: Bool
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .frame(width: 20, height: 20)
                    .foregroundColor(AppColors.text)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
            .padding(.trailing, 20)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    print("Expandable Button Pressed")
                    Haptics.impact()
                    isExpanded.toggle()
                }
            }
            // Don't remove since its displayed on a Z-Stack on MDVM
            .zIndex(1)

            Gap(12)
            
            Divider().background(AppColors.text)
            
            Gap(12)
            
            if isExpanded {
                content()
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
    }
}
