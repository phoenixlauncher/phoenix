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
                Text("Welcome to Phoenix.")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                HStack {
                    Text("Click the")
                    Image(systemName: "plus.app")
                    Text("in the top left to get started.")
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
