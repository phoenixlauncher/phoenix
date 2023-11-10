//
//  SmallToggleButton.swift
//  Phoenix
//
//  Created by James Hughes on 9/29/23.
//

import SwiftUI

struct SmallToggleButton: View {
    @Binding var toggle: Bool
    var symbol: String
    var textColor: Color
    var bgColor: Color
    
    @Default(.gradientUI) var gradientUI

    var body: some View {
        Button(action: {
            toggle.toggle()
        }) {
            Image(systemName: symbol)
                .fontWeight(.bold)
                .foregroundColor(textColor)
                .font(.system(size: 27))
        }
        .buttonStyle(.plain)
        .frame(width: 50, height: 50)
        .background(
            Group {
                if gradientUI {
                    LinearGradient(
                        colors: [bgColor,
                                 bgColor.opacity(0.7)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .cornerRadius(10) // Adjust the corner radius value as needed
                } else {
                    (bgColor)
                        .cornerRadius(10) // Adjust the corner radius value as needed
                }
            }
        )
        .cornerRadius(10)
    }
}


