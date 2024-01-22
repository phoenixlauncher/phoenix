//
//  ContextButtonMenu.swift
//  Phoenix
//
//  Created by jxhug on 1/21/24.
//

import SwiftUI

protocol CaseIterableEnum: Identifiable {
    static var allCases: [Self] { get }
    var displayName: String { get }
}

struct ContextButtonMenu<Enum: CaseIterableEnum>: View {
    
    let forEachEnum: Enum.Type
    
    let action: ((Enum) -> Void)
    let symbol: String
    let text: String
    
    var body: some View {
        Menu(content: {
            ForEach(forEachEnum.allCases) { thing in
                Button(action: { action(thing) }) {
                    Text(thing.displayName)
                }
                .accessibility(identifier: thing.displayName)
                .padding()
            }
        },
        label: {
            HStack {
                Image(systemName: symbol)
                Text(text)
            }
        })
        .accessibility(identifier: text)
    }
}
//
//#Preview {
//    ContextButtonMenu()
//}
