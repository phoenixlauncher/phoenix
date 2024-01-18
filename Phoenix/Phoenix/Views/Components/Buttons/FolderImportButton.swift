//
//  FolderImportButton.swift
//  Phoenix
//
//  Created by jxhug on 11/11/23.
//

import SwiftUI

struct FolderImportButton: View {
    @State var isImporting: Bool = false
    let type: String
    
    @Binding var folder: URL
    
    @Binding var lastPathComponent: String?
    var endPath: String?
    @Binding var invalidFolder: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(String(format: String(localized: "general_CustomFolder"), type))
                Text("\(String(localized: "general_SelectedFolder")): \(folder.path)")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            Spacer()
            Button(
                action: {
                    isImporting = true
                },
                label: {
                    Text(LocalizedStringKey("editGame_Browse"))
                }
            )
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            do {
                let selectedFolder: URL = try result.get().first ?? URL(fileURLWithPath: "")
                if let endPath = endPath, selectedFolder.lastPathComponent != endPath {
                    lastPathComponent = endPath
                    invalidFolder = true
                } else {
                    folder = selectedFolder
                }
            } catch {
                logger.write("Error selecting folder: \(error)")
            }
        }
    }
}
