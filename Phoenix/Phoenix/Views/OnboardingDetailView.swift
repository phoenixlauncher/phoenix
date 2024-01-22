//
//  OnboardingDetailView.swift
//  Phoenix
//
//  Created by jxhug on 1/19/24.
//

import SwiftUI
import Colorful

struct OnboardingDetailView: View {
    var body: some View {
        ZStack {
            ColorfulView(animated: true, animation: .smooth, colors: [.red, .orange, .red, .purple, .red, .orange], colorCount: 60)
            VStack(spacing: 20) {
                Text("Welcome to Phoenix.")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                Text("Click the 􀅼 in the top left to get started.")
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
