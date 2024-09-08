//
//  Gap.swift
//  Alethia
//
//  Created by Angelo Carasig on 6/9/2024.
//

import SwiftUI

struct Gap: View {
    let height: CGFloat
    
    init(_ height: CGFloat = 22) {
        self.height = height
    }
    
    var body: some View {
        Spacer().frame(height: height)
    }
}

#Preview {
    Gap(10)
}
