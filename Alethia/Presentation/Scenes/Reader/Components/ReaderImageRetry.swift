//
//  ReaderImageRetry.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/9/2024.
//

import SwiftUI

struct ReaderImageRetry: View {
    var callback: () -> Void
    
    var body: some View {
        Button {
            callback()
        } label: {
            Text("Retry")
                .font(.system(size: 16))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(AppColors.red)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

#Preview {
    ReaderImageRetry(callback: { print("Retried!") })
}
