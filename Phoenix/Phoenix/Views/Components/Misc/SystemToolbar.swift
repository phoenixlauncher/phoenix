//
//  SystemToolbar.swift
//  Phoenix
//
//  Created by jxhug on 5/17/24.
//

import SwiftUI

struct SystemToolbar: View {
    @Binding var selectedPlatform: Int
    @EnvironmentObject var platformViewModel: PlatformViewModel
    let plusAction: (() -> Void)
    let minusAction: (() -> Void)
    
    var body: some View {
        HStack(spacing: 0.5) {
            ListButton(imageName: "plus", action: plusAction, disabled: false)
            ListButton(imageName: "minus", action: minusAction, disabled: (platformViewModel.platforms[selectedPlatform].deletable == false))
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
