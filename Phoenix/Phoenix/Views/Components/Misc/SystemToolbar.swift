//
//  SystemToolbar.swift
//  Phoenix
//
//  Created by jxhug on 5/17/24.
//

import SwiftUI

struct SystemToolbar: View {
    let plusAction: (() -> Void)
    let minusAction: (() -> Void)
    var body: some View {
        HStack(spacing: 0.5) {
            ListButton(imageName: "plus", action: plusAction)
            ListButton(imageName: "minus", action: minusAction)
            Spacer()
        }
        .padding(.leading, 2)
        .frame(height: 25)
    }
}

struct ListButton: View {
    var imageName: String
    let action: (() -> Void)
    @State var buttonHovered: Bool = false

    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(.system(size: 15))
                .foregroundStyle(buttonHovered ? Color.primary.opacity(0.75) : .gray)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovered in
            buttonHovered = hovered
        }
        .frame(width: 25, height: 25)
    }
}
