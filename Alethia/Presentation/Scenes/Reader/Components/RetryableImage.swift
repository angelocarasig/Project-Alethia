//
//  RetryableImage.swift
//  Alethia
//
//  Created by Angelo Carasig on 18/9/2024.
//

import SwiftUI
import Kingfisher

struct RetryableImage: View {
    let url: URL
    let index: Int
    
    @State private var loadingProgress: Double? = nil
    @State private var reloadID = UUID()
    
    var body: some View {
        ZStack {
            // KFImage with a unique ID to force reloads
            KFImage(url)
                .onProgress { receivedSize, totalSize in
                    let progress = Double(receivedSize) / Double(totalSize)
                    loadingProgress = progress
                }
                .onSuccess { _ in
                    loadingProgress = 1.0
                }
                .onFailure { _ in
                    loadingProgress = 0.0
                }
                .resizable()
                .id(reloadID) // Forces KFImage to reload when reloadID changes
                .tag(index)
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            // Display the Retry button or progress indicator based on loading progress
            if let progress = loadingProgress {
                if progress == 0 {
                    // Image failed to load; show Retry button
                    ReaderImageRetry {
                        // Remove the image from cache
                        ImageCache.default.removeImage(forKey: url.absoluteString)
                        // Change reloadID to force KFImage to reload
                        reloadID = UUID()
                        // Reset loading progress
                        loadingProgress = nil
                    }
                } else if progress > 0 && progress < 1 {
                    // Image is loading; show progress indicator
                    ReaderImageProgress(progress: progress)
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
}
