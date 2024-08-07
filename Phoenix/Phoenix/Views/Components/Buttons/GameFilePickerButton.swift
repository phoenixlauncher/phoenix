//
//  GameFilePickerButton.swift
//  Phoenix
//
//  Created by Benammi Swift on 02/03/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct GameFilePickerButton: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var currentPlatform: Platform
    @Binding var game: Game
    let extraAction: ((URL) -> Void)?
    @State private var isImporting: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Game")
                if game.gameFile != game.launcher && String(format: currentPlatform.commandTemplate, "\"\(game.gameFile)\"") != game.launcher {
                    Text(String(localized: "editGame_CommandOverride"))
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else if let url = URL(string: game.gameFile) {
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
                    print(currentPlatform.gameType)
                    isImporting = true
                },
                label: {
                    Text(LocalizedStringKey("editGame_Browse"))
                }
            )
        }
        .padding()
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [UTType(tag: currentPlatform.gameType, tagClass: .filenameExtension, conformingTo: nil) ?? .data], allowsMultipleSelection: false)
        { result in
            do {
                let selectedFileURL: URL? = try result.get().first
                if let selectedFileURL = selectedFileURL {
                    extraAction?(selectedFileURL)
                    game.gameFile = selectedFileURL.path
                    game.launcher = String(format: currentPlatform.commandTemplate, "\"\(game.gameFile)\"")
                }
            }
            catch {
                logger.write(error.localizedDescription)
                appViewModel.failureToastText = "\(String(localized: "toast_LaunchCreationFailure")) \(error)"
                appViewModel.showFailureToast.toggle()
            }
       }
        .onDrop(of: [UTType(tag: currentPlatform.gameType, tagClass: .filenameExtension, conformingTo: currentPlatform.gameType == "app" ? nil : .data) ?? .data], isTargeted: nil) { selectedFile in
            handleDrop(providers: selectedFile)
            return true
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: provider.registeredTypeIdentifiers.first!, options: nil) { item, error in
                if let error = error {
                    logger.write(error.localizedDescription)
                    appViewModel.failureToastText = "\(String(localized: "toast_LaunchCreationFailure")) \(error)"
                    appViewModel.showFailureToast.toggle()
                    return
                }
                if let url = (item as? URL) {
                    extraAction?(url)
                    game.gameFile = url.path
                    game.launcher = String(format: currentPlatform.commandTemplate, "\"\(game.gameFile)\"")
                }
            }
        }
    }
}
