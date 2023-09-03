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
        .background(bgColor)
        .cornerRadius(10)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
    }
}

