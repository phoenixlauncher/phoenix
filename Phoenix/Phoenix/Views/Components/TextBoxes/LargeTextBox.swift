//
//  LargeTextBox.swift
//  Phoenix
//
//  Created by James Hughes on 9/23/23.
//

import SwiftUI

struct LargeTextBox: View {
    
    var textBoxName: String
    @Binding var input: String
    
    var body: some View {
        HStack {
            Text(textBoxName)
                .frame(width: 70, alignment: .leading)
            TextEditor(text: $input)
                .scrollContentBackground(.hidden)
                .border(Color.gray.opacity(0.1), width: 1)
                .background(Color.gray.opacity(0.05))
                .frame(minHeight: 50)
                .padding()
                .accessibility(label: Text("\(textBoxName) Input"))
        }
    }
}

