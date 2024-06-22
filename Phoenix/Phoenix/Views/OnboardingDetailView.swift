//
//  OnboardingDetailView.swift
//  Phoenix
//
//  Created by jxhug on 1/19/24.
//

import SwiftUI
import FluidGradient

struct OnboardingDetailView: View {
    var body: some View {
        ZStack {
            FluidGradient(blobs: [.orange, .pink], highlights: [.pink, .yellow, .purple], speed: 0.5, blur: 1.25)
                .background(.red)
            VStack(spacing: 20) {
                Text(String(localized: "main_Welcome"))
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                HStack {
                    Text(String(localized: "main_ClickInstruction"))
                    Image(systemName: "plus.app")
                    Text(String(localized: "main_PlusInstruction"))
                }
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .fontWeight(.medium)
            }
        }
    }
}

#Preview {
    OnboardingDetailView()
}
