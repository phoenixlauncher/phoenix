//
//  ContextButton.swift
//  Phoenix
//
//  Created by jxhug on 1/21/24.
//

import SwiftUI

struct ContextButton: View {
    
    let action: (() -> Void)
    let symbol: String
    let text: String
    
    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
            Text(text)
        }
        .accessibility(identifier: text)
    }
}

#Preview {
    ContextButton(action: {}, symbol: "gamecontroller", text: "Edit platform")
}
