//
//  DragDropFilePicker.swift
//  Phoenix
//
//  Created by Benammi Swift on 02/03/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct DragDropFilePickerButton: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var gameType: String
    @Binding var gameFile: String
    
    @State private var isImporting: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Game")
                if let url = URL(string: gameFile) {
                    Text(("\(String(localized: "editGame_Command_SelectedGame")): \(url.path)"))
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    Text(LocalizedStringKey("editGame_Command_DragDrop"))
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
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
        .padding()
        .fileImporter(isPresented: $isImporting , allowedContentTypes: [UTType(filenameExtension: gameType) ?? .data], allowsMultipleSelection: false)
        { result in
            do {
                let selectedFileURL: URL? = try result.get().first
                if let selectedFileURL = selectedFileURL {
                    gameFile = selectedFileURL.path
                }
            }
            catch {
                logger.write(error.localizedDescription)
                appViewModel.failureToastText = "Unable to create application launch command: \(error)"
                appViewModel.showFailureToast.toggle()
            }
       }
        .onDrop(of: [UTType(filenameExtension: gameType) ?? .data], isTargeted: nil) { selectedApp in
            handleDrop(providers: selectedApp)
            return true
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            print(provider)
            // Check if the dropped item is a file URL
            provider.loadItem(forTypeIdentifier: ".app", options: nil) { item, error in
                if let error = error {
                    logger.write(error.localizedDescription)
                    appViewModel.failureToastText = "Unable to create application launch command: \(error)"
                    appViewModel.showFailureToast.toggle()
                    return
                }
                if let url = (item as? URL) {
                    // Update the droppedURL state
                    gameFile = url.path
                    
                }
            }
        }
    }
}
