//
//  TextBox.swift
//  Phoenix
//
//  Created by James Hughes on 9/23/23.
//

import SwiftUI

struct TextBox: View {
    var textBoxName: String
    var caption: String?
    @Binding var input: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(textBoxName)
                if let caption = caption {
                    Text(caption)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .frame(width: caption != nil ? 150 : 70, alignment: .leading)
            RoundTextEditor(text: $input)
                .accessibility(label: Text("\(textBoxName) Input"))
        }
        .padding()
    }
}
