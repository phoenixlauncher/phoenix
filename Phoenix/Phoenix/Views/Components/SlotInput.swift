//
//  SlotInput.swift
//  Phoenix
//
//  Created by James Hughes on 9/23/23.
//

import SwiftUI

struct SlotInput<Content>: View where Content: View {
    let content: () -> Content
    var contentName: String
    
    init(contentName: String, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.contentName = contentName
    }
    
    var body: some View {
        HStack {
            Text(contentName)
                .frame(width: 70, alignment: .leading)
            content()
            .labelsHidden()
            .padding()
            .accessibility(label: Text("\(contentName) Input"))
        }
    }
}
