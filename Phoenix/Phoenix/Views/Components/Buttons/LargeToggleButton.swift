//
//  LargeToggleButton.swift
//  Phoenix
//
//  Created by James Hughes on 9/29/23.
//

import SwiftUI

struct LargeToggleButton: View {
    @Binding var toggle: Bool
    var symbol: String
    var text: String
    var textColor: Color
    var bgColor: Color
    
    @Default(.gradientUI) var gradientUI

    var body: some View {
        Button(action: {
            toggle.toggle()
        }) {
            HStack {
                Image(systemName: symbol)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                    .font(.system(size: 25))
                Text(text)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                    .font(.system(size: 25))
            }
        }
        .buttonStyle(.plain)
        .frame(width: 175, height: 50)
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
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
    }
}

