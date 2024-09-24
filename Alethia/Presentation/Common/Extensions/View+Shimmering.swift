//
//  View+Shimmering.swift
//  Alethia
//
//  Created by Angelo Carasig on 24/9/2024.
//

import SwiftUI

extension View {
    func shimmering() -> some View {
        self
            .redacted(reason: .placeholder)
            .shimmeringEffect()
    }
    
    private func shimmeringEffect() -> some View {
        return self.overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(Angle(degrees: 30))
                .offset(x: -200)
                .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false))
        )
    }
}
