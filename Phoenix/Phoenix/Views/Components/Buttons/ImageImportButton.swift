//
//  ImageImportButton.swift
//  Phoenix
//
//  Created by James Hughes on 9/23/23.
//

import SwiftUI

struct ImageImportButton: View {
    
    var type: String
    @Binding var isImporting: Bool
    @Binding var output: String
    var gameName: String
    
    var body: some View {
        HStack {
            Text(type)
                .frame(width: 70, alignment: .leading)
                .offset(x: -15)
            Button(
                action: {
                    isImporting = true
                },
                label: {
                    Text("Browse")
                })
            Text(output)
        }
        .padding()
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            if type == "Icon" {
                saveIconToFile(result: result, name: gameName) { image in
                    output = image
                }
            }
            if type == "Header" {
                saveHeaderToFile(result: result, name: gameName) { image in
                    output = image
                }
            }
        }
    }
}
