//
//  HelpButton.swift
//  Phoenix
//
//  Created by James Hughes on 9/24/23.
//

import SwiftUI

struct HelpButton: View {
    
    @Environment(\.openURL) private var openURL
    
    var url: String
    
    var body: some View {
        Button (
            action: {
                openURL(URL(string: "https://github.com/PhoenixLauncher/Phoenix/blob/main/setup.md")!)
            }, label: {
                ZStack {
                    Circle()
                        .strokeBorder(Color(NSColor.separatorColor), lineWidth: 0.5)
                        .background(Circle().foregroundColor(Color(NSColor.controlColor)))
                        .shadow(color: Color(NSColor.separatorColor).opacity(0.3), radius: 1)
                        .frame(width: 20, height: 20)
                    Text("?").font(.system(size: 15, weight: .regular))
                }
            }
        )
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
}
