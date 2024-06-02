//
//  FolderImportButton.swift
//  Phoenix
//
//  Created by jxhug on 11/11/23.
//

import SwiftUI

struct FolderImportButton: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State var isImporting: Bool = false
    let type: String
    
    @Binding var folder: URL
    
    var endPath: String?
    
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
                    appViewModel.failureToastText = "Folder must end with \"\(endPath)\"."
                    appViewModel.showSettingsFailureToast.toggle()
                } else {
                    folder = selectedFolder
                }
            } catch {
                logger.write("Error selecting folder: \(error)")
            }
        }
        .onDrop(of: [type], isTargeted: nil) { selectedFile in
            handleDrop(providers: selectedFile)
            return true
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: provider.registeredTypeIdentifiers.first!, options: nil) { item, error in
                if let error = error {
                    logger.write(error.localizedDescription)
                    appViewModel.failureToastText = "Unable to create application launch command: \(error)"
                    appViewModel.showSettingsFailureToast.toggle()
                    return
                }
                if let selectedFolder = (item as? URL) {
                    if let endPath = endPath, selectedFolder.lastPathComponent != endPath {
                        appViewModel.failureToastText = "Folder must end with \"\(endPath)\"."
                        appViewModel.showSettingsFailureToast.toggle()
                    } else {
                        folder = selectedFolder
                    }
                }
            }
        }
    }
}
