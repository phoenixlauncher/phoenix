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
    var gameID: UUID
    
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
            resultIntoData(result: result) { data in
                if type == "Icon" {
                    saveIconToFile(iconData: data, gameID: gameID) { image in
                        output = image
                    }
                } else if type == "Header" {
                    saveHeaderToFile(headerData: data, gameID: gameID) { image in
                        output = image
                    }
                }
            }
        }
    }
}
