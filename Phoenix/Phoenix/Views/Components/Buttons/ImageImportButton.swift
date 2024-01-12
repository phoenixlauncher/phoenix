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
    @Binding var input: String
    @Binding var output: String
    var gameID: UUID
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(type)
                Text("\(String(localized: "editGame_SelectedImage")): \(input)")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            Spacer()
            Button(
                action: {
                    isImporting = true
                },
                label: {
                    Text(String(localized: "editGame_Browse"))
                }
            )
            .accessibilityLabel("\(type) Input")
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            input = (try? result.get().first?.path) ?? ""
            resultIntoData(result: result) { data in
                if type == "Icon" {
                    saveIconToFile(iconData: data, gameID: gameID) { image in
                        output = image
                    }
                } else {
                    saveImageToFile(data: data, gameID: gameID, type: type) { image in
                        output = image
                    }
                }
            }
        }
        .padding()
    }
}
