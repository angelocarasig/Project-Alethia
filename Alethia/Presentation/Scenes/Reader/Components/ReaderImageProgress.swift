//
//  ReaderImageProgress.swift
//  Alethia
//
//  Created by Angelo Carasig on 15/9/2024.
//

import SwiftUI

struct ReaderImageProgress: View {
    var progress: Double // Between 0.0 and 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.tint.opacity(0.3), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(AppColors.text, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90)) // Start progress from the top
                .animation(.easeInOut, value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .bold()
                .foregroundColor(AppColors.text) // Text in white
        }
        .frame(width: 50, height: 50) // Size of the progress view
    }
}

#Preview {
    ReaderImageProgress(progress: 0.2)
}
