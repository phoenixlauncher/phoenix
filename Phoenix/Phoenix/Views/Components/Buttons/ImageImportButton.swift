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
                resultIntoData(result: result) { data in
                    saveIconToFile(iconData: data, name: gameName) { image in
                        output = image
                    }
                }
            }
            if type == "Header" {
                resultIntoData(result: result) { data in
                    saveHeaderToFile(headerData: data, name: gameName) { image in
                        output = image
                    }
                }
            }
        }
    }
}
