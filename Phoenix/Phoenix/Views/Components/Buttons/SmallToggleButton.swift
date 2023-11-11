//
//  SmallToggleButton.swift
//  Phoenix
//
//  Created by James Hughes on 9/29/23.
//

import SwiftUI

import SwiftUI

struct SmallToggleButton: View {
    @Binding var toggle: Bool
    var symbol: String
    var textColor: Color
    var bgColor: Color

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
        .background(bgColor)
        .cornerRadius(10)
    }
}


