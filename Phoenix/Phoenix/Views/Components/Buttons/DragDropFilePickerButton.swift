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
    
    @Binding var launcher: String
    
    @State private var isImporting: Bool = false
    @State var appURL: URL?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Game")
                let path = (launcher.range(of: #""([^"]+)""#, options: .regularExpression) != nil) ? String(launcher[launcher.range(of: #""([^"]+)""#, options: .regularExpression)!].dropFirst().dropLast()) : ""
                if let url = URL(string: path) {
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
        .fileImporter(isPresented: $isImporting , allowedContentTypes: [.application], allowsMultipleSelection: false)
        { result in
            do {
                let selectedAppURL: URL? = try result.get().first
                if let selectedAppURL = selectedAppURL {
                    appURL = selectedAppURL
                    launcher = "open \"\(selectedAppURL.absoluteString)\""
                }
            }
            catch {
                logger.write(error.localizedDescription)
                appViewModel.failureToastText = "Unable to create application launch command: \(error)"
                appViewModel.showFailureToast.toggle()
            }
       }
        .onDrop(of: [.application], isTargeted: nil) { selectedApp in
            handleDrop(providers: selectedApp)
            return true
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            print(provider)
            // Check if the dropped item is a file URL
            provider.loadItem(forTypeIdentifier: UTType.application.identifier, options: nil) { item, error in
                if let error = error {
                    logger.write(error.localizedDescription)
                    appViewModel.failureToastText = "Unable to create application launch command: \(error)"
                    appViewModel.showFailureToast.toggle()
                    return
                }
                if let url = (item as? URL) {
                    // Update the droppedURL state
                    appURL = url
                    launcher = "open \"\(url.absoluteString)\""
                }
            }
        }
    }
}
