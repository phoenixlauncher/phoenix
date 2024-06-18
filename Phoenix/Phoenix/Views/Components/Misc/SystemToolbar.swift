//
//  SystemToolbar.swift
//  Phoenix
//
//  Created by jxhug on 5/17/24.
//

import SwiftUI

struct SystemToolbar: View {
    let plusAction: (() -> Void)
    let plusDisabled: Bool
    let minusAction: (() -> Void)
    let minusDisabled: Bool
    
    var body: some View {
        HStack(spacing: 0.5) {
            ListButton(imageName: "plus", action: plusAction, disabled: plusDisabled)
            ListButton(imageName: "minus", action: minusAction, disabled: minusDisabled)
            Spacer()
        }
        .frame(height: 30)
    }
}

struct ListButton: View {
    var imageName: String
    let action: (() -> Void)
    let disabled: Bool
    @State var buttonHovered: Bool = false

    var body: some View {
        Button(action: {
            if !disabled {
                action()
            }
        }) {
            Image(systemName: imageName)
                .frame(width: 30, height: 30)
                .font(.system(size: 17))
                .foregroundStyle((buttonHovered && !disabled) ? Color.primary.opacity(0.75) : .gray)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { hovered in
            buttonHovered = hovered
        }
        .frame(width: 30, height: 30)
    }
}
